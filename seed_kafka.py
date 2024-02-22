import psycopg2
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
        logging.warning(f'Topic {topic_name} already exists, deleting it')
        admin_client.delete_topics([topic_name])[topic_name].result()
    admin_client.create_topics([topic])[topic_name].result()

    if check_kafka_topic_created(env, topic_name):
        logging.info(f'Topic {topic_name} created')
    else:
        logging.error(f'Topic {topic_name} not created')
        raise Exception(f'Topic {topic_name} not created')


def send_records_to_kafka(env, records):
    producer = env.producer
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


def send_parquet_records(env, parquet_file):
    table = pq.read_table(parquet_file)
    records = table.to_pandas()
    send_records_to_kafka(env, records)


def check_connection(conn):
    cur = conn.cursor()
    logging.info('Checking connection to the RisingWave')
    cur.execute("SELECT version();")
    result = cur.fetchone()
    if result is None:
        logging.error('Connection failed')
        raise Exception('Connection failed')
    conn.commit()
    logging.info(f'RisingWave started with version: {result[0]}')


def send_csv_records(env, csv_file):
    records = pandas.read_csv(csv_file)
    # connect to risingwave via psycopg2
    conn = psycopg2.connect(
        host="localhost",
        database="dev",
        user="root",
        port=4566,
    )
    conn.set_session(autocommit=True)
    check_connection(conn)
    # For each record in the csv file, insert it into the database
    cur = conn.cursor()
    # Recreate table if it exists
    cur.execute("DROP TABLE IF EXISTS taxi_zone;")
    cur.execute(
        """
        CREATE TABLE taxi_zone (
            location_id int,
            borough text,
            zone text,
            service_zone text
        )
        """
    )
    logging.info('Created taxi_zone table')
    for i, record in records.iterrows():
        location_id = record['LocationID']
        borough = record['Borough']
        zone = record['Zone']
        service_zone = record['service_zone']
        cur.execute(
            f"""
            INSERT INTO taxi_zone (location_id, borough, zone, service_zone)
            VALUES (%s, %s, %s, %s);
            """,
            (location_id, borough, zone, service_zone))
    cur.execute("flush;")
    conn.commit()
    conn.close()
    logging.info(f'Created {len(records)} records in taxi_zone table')


def main():
    conf = {
        'bootstrap.servers': "localhost:9092",
        "queue.buffering.max.messages": 1000000
    }
    env = Env(conf)

    # Load taxi zone data
    taxi_zone_filepath = 'data/taxi_zone.csv'
    send_csv_records(env, taxi_zone_filepath)

    # Load trip data
    trip_data_topic = 'trip_data'
    trip_data_filepath = 'data/yellow_tripdata_2022-01.parquet'
    create_kafka_topic(env, trip_data_topic)
    send_parquet_records(env, trip_data_filepath)


main()
