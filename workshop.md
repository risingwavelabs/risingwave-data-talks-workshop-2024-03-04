# Stream Processing in SQL with RisingWave

Before beginning on this section, make sure you have setup your environment according to the [README](./README.md).

## What is RisingWave?

For this section the content is derived from:
- https://tutorials.risingwave.com/docs/intro
- https://tutorials.risingwave.com/docs/faq
- https://tutorials.risingwave.com/docs/design/architecture
- https://tutorials.risingwave.com/docs/design/state

Please consult those sections for more details.

## Setting up RisingWave with Docker Compose

Reference: https://docs.risingwave.com/docs/current/risingwave-docker-compose/

For this workshop, I have slightly modified the `docker-compose.yml` file to include clickhouse as well.

The `docker-compose.yml` file is located in the `docker` directory.

The docker-compose file has the following structure ... TODO.

## Ingesting Data into RisingWave using Kafka

Reference: https://docs.risingwave.com/docs/current/ingest-from-kafka/

The `seed_kafka.py` file contains the logic to process the data and populate RisingWave.

TODO: Explain logic in `seed_kafka.py`.

## Using `psycopg2` to connect to RisingWave and run SQL queries

Reference: https://docs.risingwave.com/docs/current/python-client-libraries/#connect-to-risingwave

TODO: Explain logic in `seed_kafka.py`

## Stream Processing with Materialized Views in RisingWave

TODO: Explain each MV
TODO: Construct the MVs from scratch showing how they can be built.

## Simple Batch Query Serving with RisingWave

TODO: Explain each Batch

## How to sink data from RisingWave to Clickhouse

TODO: Explain each sink

## What's next?

TODO: What's next?

## Homework

To further understand the concepts, please try the [Homework](./homework.md).