import json
import datetime
from kafka import KafkaProducer
import os

def handler(event, context):
    current_time = datetime.datetime.now().isoformat()
    message = {'current_time': current_time}

    producer = KafkaProducer(
        bootstrap_servers=os.environ['MSK_BOOTSTRAP_SERVERS'].split(','),
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )

    producer.send(os.environ['MSK_TOPIC'], message)
    producer.flush()

    return {
        'statusCode': 200,
        'body': 'Message sent: ' + json.dumps(message)
    }
