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


