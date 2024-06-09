import os
import boto3
import time
from datetime import datetime, timedelta
from kafka import KafkaConsumer

from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

# Environment variables
TOPIC = os.environ['TOPIC']
BROKER_STRING = os.environ['BS']

class MSKTokenProvider():
    def token(self):
        token, _ = MSKAuthTokenProvider.generate_auth_token('us-east-1')
        return token

def create_kafka_consumer():
    # Create Kafka consumer with IAM authentication

    tp = MSKTokenProvider()


    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=os.getenv('BS'),
        security_protocol="SASL_SSL",
        sasl_mechanism="OAUTHBEARER",
        sasl_oauth_token_provider=tp,
        auto_offset_reset='earliest',  # FIXME: not efficient
        enable_auto_commit=False
    )
    return consumer

def lambda_handler(event, context):
    # Initialize Kafka consumer
    consumer = create_kafka_consumer()

    # Calculate the timestamp for 3 minutes ago
    three_minutes_ago = datetime.now() - timedelta(minutes=3)
    three_minutes_ago_timestamp = int(time.mktime(three_minutes_ago.timetuple()) * 1000)

    # Poll messages
    messages = []
    for message in consumer:
        if message.timestamp >= three_minutes_ago_timestamp:
            messages.append(message)
        if datetime.now() - three_minutes_ago > timedelta(minutes=3):
            break

    # Output each message
    for message in messages:
        print(f"Received message: {message.value.decode('utf-8')}, Timestamp: {message.timestamp}")

    # Close consumer
    consumer.close()

    return {
        'statusCode': 200,
        'body': 'Processed last 3 minutes of messages'
    }
