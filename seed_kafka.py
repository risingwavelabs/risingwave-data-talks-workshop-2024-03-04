import concurrent.futures
import pyarrow.parquet as pq
from confluent_kafka import Producer
from confluent_kafka.admin import AdminClient, NewTopic
import pandas
import socket
import time
import logging

logging.basicConfig()
logging.root.setLevel(logging.INFO)


class Env:
    def __init__(self, conf):
        self.conf = conf
        self.producer = Producer(conf)
        self.admin_client = AdminClient(conf)


def check_kafka_topic_created(env, topic):
    admin_client = env.admin_client
    cluster_metadata = admin_client.list_topics()
    return topic in cluster_metadata.topics.keys()


def create_kafka_topic(env, topic_name):
    admin_client = env.admin_client
    topic = NewTopic(topic=topic_name, num_partitions=8, replication_factor=1)
    if check_kafka_topic_created(env, topic_name):
        logging.warning(f"Topic {topic_name} already exists, deleting it")
        admin_client.delete_topics([topic_name])[topic_name].result()
    admin_client.create_topics([topic])[topic_name].result()


def send_parquet_records(env, parquet_file):
    producer = env.producer
    table = pq.read_table(parquet_file)
    schema = table.schema
    records = table.to_pandas()

    records_count = len(records)
    logging.info(f"Sending {records_count} records to Kafka")
    for i, (_, record) in enumerate(records.iterrows()):
        if i % 100000 == 0:
            logging.info(f"Sent {i} records")
        message = record.to_json()
        producer.produce('trip_data', value=message.encode(), key=None)
        if i % env.conf["queue.buffering.max.messages"] == 0:
            producer.flush()
    producer.flush()
    logging.info(f"Sent {records_count} records to Kafka")


def main():
    conf = {
        'bootstrap.servers': "localhost:9092",
        "queue.buffering.max.messages": 1000000
    }
    env = Env(conf)

    topic = 'trip_data'
    filepath = 'yellow_tripdata_2022-01.parquet'

    create_kafka_topic(env, topic)
    created = check_kafka_topic_created(env, topic)
    if created:
        logging.info(f"Topic {topic} created")
    else:
        logging.error(f"Topic {topic} not created")
        raise Exception(f"Topic {topic} not created")

    send_parquet_records(env, filepath)


main()
