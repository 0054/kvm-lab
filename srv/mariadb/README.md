# mariadb

## создание кластера master-master

master1 - 10.10.1.23
master2 - 10.10.1.24
app - 10.10.1.200

```
yum install mariadb-server
```
#### настройка 
конфиг /etc/my.cnf
```
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
[mariadb]
log-bin
server_id=1 # 2 на мастере2
log-error=/var/log/mariadb/mariadb.err
log-basename=db1 
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
```

на мастере1
```
create user 'replicator'@'%' identified by 'password';
grant replication slave on *.* to 'replicator'@'%';
show master status;
```
получим следующий вывод
```
MariaDB [(none)]> show master status;
+----------------+----------+--------------+------------------+
| File           | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+----------------+----------+--------------+------------------+
| db1-bin.000003 |      482 |              |                  |
+----------------+----------+--------------+------------------+
1 row in set (0.00 sec)

```

на мастере2
в MASTER_LOG_POS указываем вывод из колонки Position
```
create user 'replicator'@'%' identified by 'password';
grant replication slave on *.* to 'replicator'@'%';
slave stop;
CHANGE MASTER TO MASTER_HOST = '10.10.1.23', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'db1-bin.000003', MASTER_LOG_POS = 482;
slave start;
show master status;
+----------------+----------+--------------+------------------+
| File           | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+----------------+----------+--------------+------------------+
| db1-bin.000003 |      482 |              |                  |
+----------------+----------+--------------+------------------+
1 row in set (0.00 sec)

```

на мастере1
```
slave stop;
CHANGE MASTER TO MASTER_HOST = '10.10.1.24', MASTER_USER = 'replicator', MASTER_PASSWORD = 'password', MASTER_LOG_FILE = 'db1-bin.000003', MASTER_LOG_POS = 482;
slave start;
```


создание базы и открытие доступа
```
create database testdb;
create user dbuser identified by 'q1'
GRANT USAGE ON *.* TO 'dbuser'@'10.10.1.200' IDENTIFIED BY 'q1';
GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' WITH GRANT OPTION;
grant all privileges on testdb.* to dbuser
```



