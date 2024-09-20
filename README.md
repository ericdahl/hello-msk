# hello-msk

## Topic Setup
```
# export BS=<your bootstrap server>

# /kafka/bin/kafka-topics.sh --bootstrap-server $BS --command-config client.properties --create --topic HelloWorld --partitions 1 
Created topic HelloWorld.
# /kafka/bin/kafka-topics.sh --bootstrap-server $BS --command-config client.properties --list
HelloWorld
# /kafka/bin/kafka-topics.sh --bootstrap-server $BS --command-config client.properties --describe 
Topic: HelloWorld	TopicId: nxMsNnfSTMmAFDljWMU--Q	PartitionCount: 1	ReplicationFactor: 3	Configs: min.insync.replicas=2,segment.bytes=134217728,retention.ms=604800000,message.format.version=2.8-IV2,unclean.leader.election.enable=false,retention.bytes=268435456000
	Topic: HelloWorld	Partition: 0	Leader: 296	Replicas: 296,280,284	Isr: 296,280,284
```

## Console Produce/Consume

```
# /kafka/bin/kafka-console-producer.sh --bootstrap-server $BS --producer.config /kafka/bin/client.properties --topic HelloWorld
>hello


# /kafka/bin/kafka-console-consumer.sh --bootstrap-server $BS --consumer.config /kafka/bin/client.properties --from-beginning --topic HelloWorld
hello
^C
Processed a total of 1 messages
```

```
# /kafka/bin/kafka-consumer-groups.sh --bootstrap-server $BS --command-config client.properties --describe --group lambda-consumer

Consumer group 'lambda-consumer' has no active members.

GROUP           TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
lambda-consumer HelloWorld      0          84              98              14              -               -               -
```

# Notes

## IAM

### Service Prefixes

- `kafka-cluster`: Kafka specific operations, mapping to particular ACLs (e.g., CreateTopic, ReadData)
- `kafka`: create/modify MSK clusters (v1 or v2)
- `kafkaconnect`: Kafka Connect specific APIs

# TODO

- swap to MSK provisioned
- multiple Lambda consumers with diff consumer groups?
- set consumer-id / host / client-id ?
- TF for Kafka topics.. ?
- 