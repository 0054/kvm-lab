# Kafka



- данные по группе подписчиков
```
./kafka-consumer-groups.sh --describe --group logstash --bootstrap-server localhost:9092
```
- список топиков
```
./kafka-topics.sh --zookeeper localhost:2181 --list
```
- список групп
```
./kafka-consumer-groups.sh --list  --bootstrap-server localhost:9092
```



# kafka SSL

[manual](https://www.vertica.com/docs/9.2.x/HTML/Content/Authoring/KafkaIntegrationGuide/TLS-SSL/KafkaTLS-SSLExamplePart3ConfigureKafka.htm?TocPath=Integrating%20with%20Apache%20Kafka|Using%20TLS%2FSSL%20Encryption%20with%20Kafka|_____7)

создаём приватный ключ root.key
```
openssl genrsa -out root.key
```
создание самозаверенного корневого сертификата
```
openssl req -new -x509 -key root.key -out root.crt
```
создаём truststore файл который будет использоваться для брокеров и клиентов.
этот truststore будет содержать только root.crt:
```
keytool -keystore kafka.truststore.jks -alias CARoot -import -file root.crt
```
создаём keystore для каждого брокера кластера:
```
keytool -keystore vm101.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:vm101.example.com
keytool -keystore vm102.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:vm102.example.com
keytool -keystore vm103.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:vm103.example.com
```
будет запущен примерно такой диалог в нём для нас критично отверить на вопрос "What is your first and last name?" указав полный хостнейм брокера по которому к нему будут ходить так же как и в опции "-ext SAN=DNS"
например:
```
Enter keystore password: some_password
Re-enter new password: some_password
What is your first and last name?
  [Unknown]:  vm101.example.com
What is the name of your organizational unit?
  [Unknown]:  
What is the name of your organization?
  [Unknown]: MyCompany
What is the name of your City or Locality?
  [Unknown]:  Cambridge
What is the name of your State or Province?
  [Unknown]:  Unknown
What is the two-letter country code for this unit?
  [Unknown]:  RU
Is CN=vm101.example.com, OU=MyCompany, O=Unknown, L=Cambridge, ST=Unknown, C=RU correct?
  [no]:  yes

Enter key password for <localhost>
        (RETURN if same as keystore password): 
```

экспортируем сертификаты для того чтобы их можно было подписать:
```
keytool -keystore vm101.keystore.jks -alias localhost -certreq -file vm101.unsigned.crt
keytool -keystore vm102.keystore.jks -alias localhost -certreq -file vm102.unsigned.crt
keytool -keystore vn103.keystore.jks -alias localhost -certreq -file vn103.unsigned.crt
```
подписываем сертификаты брокеров кафки:
```
openssl x509 -req -CA root.crt -CAkey root.key -in vm101.unsigned.crt -out vm101.signed.crt -days 365 -CAcreateserial
openssl x509 -req -CA root.crt -CAkey root.key -in vm102.unsigned.crt -out vm102.signed.crt -days 365 -CAcreateserial
openssl x509 -req -CA root.crt -CAkey root.key -in vn103.unsigned.crt -out vn103.signed.crt -days 365 -CAcreateserial
```
инпортируем корневой CA в keystore каждого брокера:

```
keytool -keystore vm101.keystore.jks -alias CARoot -import -file root.crt
keytool -keystore vm102.keystore.jks -alias CARoot -import -file root.crt
keytool -keystore vn103.keystore.jks -alias CARoot -import -file root.crt
```
импортируем самоподписанные сертификаты брокеров обратно в свои keystore:
```
keytool -keystore vm101.keystore.jks -alias localhost -import -file vm101.signed.crt
keytool -keystore vm102.keystore.jks -alias localhost -import -file vm102.signed.crt
keytool -keystore vn103.keystore.jks -alias localhost -import -file vn103.signed.crt
```

раскидываем по нодам кафки наши серты
для каждой ноды нужен свой keystore (напр. vm102.keystore.jks) и общий truststore kafka.truststore.jks
конфигурируем кафку /etc/kafka/server.properties
например так:
```
broker.id=1
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/var/lib/kafka
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0
listeners=PLAINTEXT://:9092,SSL://:9093
ssl.keystore.location=/opt/kafka/ssl/vm101.keystore.jks
ssl.keystore.password=P@ssw0rd
ssl.key.password=P@ssw0rd
ssl.truststore.location=/opt/kafka/ssl/kafka.truststore.jks
ssl.truststore.password=P@ssw0rd
ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
ssl.client.auth=required
```
меняем на каждой ноде broker.id=№ и пути до keystore и trutstore


для клиентов генерируем свой keystore:

```
keytool -keystore vm104.client.keystore.jks -alias localhost -validity 365 -genkey -keyalg RSA -ext SAN=DNS:vm104.example.com
```
экспортируем сертификат:
```
keytool -keystore vm104.client.keystore.jks -alias localhost -certreq -file vm104.client.unsigned.cert
```
подписываем его:
```
openssl x509 -req -CA root.crt -CAkey root.key -in vm104.client.unsigned.cert -out vm104.client.signed.cert -days 365 -CAcreateserial
```
импортируем root.crt:
```
keytool -keystore vm104.client.keystore.jks -alias CARoot -import -file root.crt
```
импортируем подписанный сертификат клиента:
```
keytool -keystore vm104.client.keystore.jks -alias localhost -import -file vm104.client.signed.cert
```

## проверка kafka ssl

конфиг клиента client-ssl.properties:
```
security.protocol=SSL
ssl.truststore.location=/opt/kafka/ssl/kafka.truststore.jks
ssl.truststore.password=P@ssw0rd
ssl.keystore.location=/opt/kafka/ssl/vm104.client.keystore.jks
ssl.keystore.password=P@ssw0rd
ssl.key.password=P@ssw0rd
ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
ssl.client.auth=required
```

запускаем своего продюсера:

```
./bin/kafka-console-producer.sh --broker-list vm102.example.com:9093 --topic test2 --producer.config client-ssl.properties
>test
>test again
>More testing. These messages seem to be getting through!
^D
```
запускаем своего консьюмера:

```
./bin/kafka-console-consumer.sh --bootstrap-server vm102.example.com:9093  --topic test2 --consumer.config client-ssl.properties --from-beginning
test
test again
More testing. These messages seem to be getting through!
^C
Processed a total of 3 messages
```

# kafka SASL SSL

тастраиваем всё как и раньше кроме клиентских сертификатов
правим конфигурацию /etc/kafka/server.properties
```
broker.id=1
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
log.dirs=/var/lib/kafka
num.partitions=1
num.recovery.threads.per.data.dir=1
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=6000
group.initial.rebalance.delay.ms=0

listeners=SSL://:9093,SASL_SSL://:9094
security.inter.broker.protocol=SSL
ssl.client.auth=required
ssl.keystore.location=/opt/kafka/ssl/vm101.keystore.jks
ssl.keystore.password=P@ssw0rd
ssl.key.password=P@ssw0rd
ssl.truststore.location=/opt/kafka/ssl/kafka.truststore.jks
ssl.truststore.password=P@ssw0rd
ssl.enabled.protocols=TLSv1.2,TLSv1.1,TLSv1
sasl.mechanism.inter.broker.protocol=PLAIN
sasl.enabled.mechanisms=PLAIN
```

тут мы создали listner на 9094 который работает по SASL SSL

тaк же создаём jaas конфиг
/etc/kafka/kafka_server_jaas.conf:
```
KafkaServer {
    org.apache.kafka.common.security.plain.PlainLoginModule required
    username="admin"
    password="q1q1q1"
    user_admin="q1q1q1";
};
```
задаём логин и пароль

чтобы это заработало кафке надо при запуске передать параметр c путём до этого конфига 
выглядит так:
```
-Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
```

например стандартный RPM пакет для centos передаёт параметры запуска забирая их из
/etc/sysconfig/kafka
```
KAFKA_SERVER_CONFIG=/etc/kafka/server.properties
KAFKA_LOG4J_OPTS=-Dkafka.logs.dir=/var/log/kafka -Dlog4j.configuration=file:///etc/kafka/log4j.properties
KAFKA_GC_LOG_OPTS=-Xloggc:/var/log/kafka/kafkaServer-gc.log -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps
KAFKA_JVM_PERFORMANCE_OPTS=-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+DisableExplicitGC -Djava.awt.headless=true
KAFKA_JMX_OPTS=-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.security.auth.login.config=/etc/kafka/kafka_server_jaas.conf
```
добавим наш параметр к KAFKA_JMX_OPTS

на этом настройка сервера закончилась
клиенту необходимо предоставить truststore из предыдущей настройки пароль от него и логин пароль SASL:
```
kafka.security.protocol = SASL_SSL
kafka.ssl.truststore.location = kafka.truststore.jks
kafka.ssl.truststore.password = P@ssw0rd
kafka.ssl.key.password = P@ssw0rd
kafka.sasl.mechanism = PLAIN
kafka.sasl.password = q1q1q1
kafka.sasl.username = admin
```

SASL логин и пароль некоторые клиенты могут принимать файле с таким содержанием:
```
KafkaClient {
  org.apache.kafka.common.security.plain.PlainLoginModule required
  username="admin"
  password="q1q1q1";
};
```
