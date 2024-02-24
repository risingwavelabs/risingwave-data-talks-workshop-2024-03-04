# Stream Processing NYC Taxi Data with RisingWave

In this tutorial, we will show you how to use RisingWave to process NYC Taxi data in real-time.
We will use the NYC Taxi dataset, which contains information about taxi trips in New York City.
We will use RisingWave to ingest the data, process it in real-time, and store the results in a Clickhouse database.

## Note on the dataset

The NYC Taxi dataset is a public dataset that contains information about taxi trips in New York City.
The dataset is available in Parquet format and can be downloaded from the [NYC Taxi & Limousine Commission website](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page).

We will be using the following files from the dataset:
- `yellow_tripdata_2022-01.parquet`
- `taxi_zone.csv`

For your convenience, these have already been downloaded and are available in the `data` directory.