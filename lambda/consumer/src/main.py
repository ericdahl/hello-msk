import os
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider
from kafka import KafkaConsumer


class MSKTokenProvider():
    def token(self):
        token, _ = MSKAuthTokenProvider.generate_auth_token('us-east-1')
        return token


def create_kafka_consumer():
    tp = MSKTokenProvider()

    consumer = KafkaConsumer(
        os.environ['TOPIC'],
        bootstrap_servers=os.environ["BS"],
        security_protocol="SASL_SSL",
        sasl_mechanism="OAUTHBEARER",
        group_id=os.environ["GROUP_ID"],
        auto_offset_reset="earliest",
        sasl_oauth_token_provider=tp,
        enable_auto_commit=True
    )
    return consumer


def lambda_handler(event, context):
    consumer = create_kafka_consumer()

    msg_pack = consumer.poll(timeout_ms=60000)

    for topic_partition, msgs in msg_pack.items():
        print(topic_partition)
        for message in msgs:
            print(f"  Msg offset={message.offset} / value={message.value.decode('utf-8')}")

    consumer.close()

    return {
        'statusCode': 200,
    }
