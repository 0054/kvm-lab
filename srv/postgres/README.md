# postgres


## бекап

с удалённого сервера
```
pg_dump -U postgres -h 10.10.10.10 -d db_name --exclude-table='table_name' -F t > db_name.dump
```



## Кластер

### сборка кластера при одной работающей бд

если в основной бд не включен archive_mode то без даунтайма настроить репликацию не получится

дано:
- 10.10.10.1 pg1 работающая бд
- 10.10.10.2 pg2 новый пустой сервер со свеже установленной бд
- 10.10.10.3 zk сервер с зукипером, для теста один, для прода 3+


кластер на основе patroni + zookeeper(можно заменить на то что есть)
допустим у нас centos7
на обоих нодах
```
yum install python36 gcc python3-devel postgresql-devel
pip3 install patroni[zookeeper] psycopg2
```

создаём конфиг patroni /etc/patroni.yml
```
scope: pg-cluster # название кластера 
namespace: /db/ # название директории в зукипере
name: pg-1 # имя ноды уникальное для каждой ноды

restapi:
  listen: 0.0.0.0:8008 # адрес на котором будет слушать патрони
  connect_address: 10.10.10.1:8008 # адрес по которому наш патрони будут искать другие сервисы

zookeeper:
  hosts: 10.10.10.3:2181 # либо в скобках [1.1.1.1:2181, 2.2.2.2:2181, ...]

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 10
    maximum_lag_on_failover: 1048576
    postgresql:
      use_pg_rewind: true
      use_slots: true
      parameters:
        wal_level: replica
        hot_standby: "on"
        wal_keep_segments: 8
        max_wal_senders: 5
        max_replication_slots: 5
        checkpoint_timeout: 30
  initdb:
  - encoding: UTF8
  - data-checksums
  pg_hba:
  - host all all 0.0.0.0/0 md5
  - host replication repl 0.0.0.0/0 md5
  users:
    postgres:
      password: q1
      options:
        - createrole
        - createdb
    repl:
      password: q1
      options:
        - replication

postgresql:
  listen: '0.0.0.0/0' # cлушаем на всех интерфейсах
  connect_address: 10.10.10.1:5432 # адрес по которому будет искать нас другая база
  data_dir: /var/lib/pgsql/11/data 
  bin_dir: /usr/pgsql-11/bin/
  #pgpass: /tmp/pgpass
  authentication:
      replication:
      username: repl
      password: q1
    superuser:
      username: postgres
      password: q1
```

создаём сервис для patroni:
/etc/systemd/system/patroni.service

```
Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target
 
[Service]
Type=simple
User=postgres
Group=postgres
ExecStart=/bin/patroni /etc/patroni.yml
KillMode=process
TimeoutSec=30
Restart=no
 
[Install]
WantedBy=multi-user.target
```

в конфиге postgres на мастере меняем:
/var/lib/pgsql/11/data/pg_hba.conf
```
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
host    all             all             0.0.0.0/0               md5
host    replication     repl            0.0.0.0/0               md5
```

создаём пользователя для репликации:
```
CREATE USER repl WITH REPLICATION ENCRYPTED PASSWORD 'q1';
```

далее останавливаем базу на мастере и запускаем под патрони
```
systemctl stop postgresql-11-server
systemctl disable postgresql-11-server
systemctl start patroni.service
```

проверям на наличие ошибок + утилитой patronictl
```
patronictl -c /etc/patroni.yml list
+------------+--------+--------------+--------+---------+----+-----------+
|  Cluster   | Member |     Host     |  Role  |  State  | TL | Lag in MB |
+------------+--------+--------------+--------+---------+----+-----------+
| pg-cluster |  pg-1  | 10.10.10.1   | Leader | running |  3 |           |
+------------+--------+--------------+--------+---------+----+-----------+
```

если всё ОК то запускаем stb ноду:
```
systemctl start patroni.service
patronictl -c /etc/patroni.yml list
+------------+--------+--------------+--------+------------------+----+-----------+
|  Cluster   | Member |     Host     |  Role  |      State       | TL | Lag in MB |
+------------+--------+--------------+--------+------------------+----+-----------+
| pg-cluster |  pg-2  | 10.10.10.2   |        | creating replica |    |   unknown |
| pg-cluster |  pg-1  | 10.10.10.1   | Leader |     running      |  3 |           |
+------------+--------+--------------+--------+------------------+----+-----------+
```
если всё ОК то видим что началось создание реплики
а потом:
```
patronictl -c /etc/patroni.yml list
+------------+--------+--------------+--------+---------+----+-----------+
|  Cluster   | Member |     Host     |  Role  |  State  | TL | Lag in MB |
+------------+--------+--------------+--------+---------+----+-----------+
| pg-cluster |  pg-2  | 10.10.31.2   |        | running |    |         0 |
| pg-cluster |  pg-1  | 10.10.31.1   | Leader | running |  3 |           |
+------------+--------+--------------+--------+---------+----+-----------+
```

можно подгрузить конфиг без ребута
```

/usr/pgsql-11/bin/pg_ctl reload -D /var/lib/pgsql/11/data/
```

чеклист:
- различия в конфигах patroni только название ноды и IP
- на мастер ноде обязательно исправить pg_hba.conf
- на мастер ноде создать необходимого пользователя с правами
- логины и пароли должны быть везде одинаковые те их копируем с мастера
- задизейблить сервис postgres

