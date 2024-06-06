# hello-msk

```
kafka-topics.sh --list --bootstrap-server $BS --command-config client.properties

Traceback (most recent call last):
  File "/root/main.py", line 14, in <module>
    producer = KafkaProducer(
  File "/root/.venv/lib64/python3.9/site-packages/kafka/producer/kafka.py", line 381, in __init__
    client = KafkaClient(metrics=self._metrics, metric_group_prefix='producer',
  File "/root/.venv/lib64/python3.9/site-packages/kafka/client_async.py", line 244, in __init__
    self.config['api_version'] = self.check_version(timeout=check_timeout)
  File "/root/.venv/lib64/python3.9/site-packages/kafka/client_async.py", line 927, in check_version
    raise Errors.NoBrokersAvailable()
kafka.errors.NoBrokersAvailable: NoBrokersAvailable
```

# Notes

## IAM

### Service Prefixes

- `kafka-cluster`: Kafka specific operations, mapping to particular ACLs (e.g., CreateTopic, ReadData)
- `kafka`: create/modify MSK clusters (v1 or v2)
- `kafkaconnect`: Kafka Connect specific APIs