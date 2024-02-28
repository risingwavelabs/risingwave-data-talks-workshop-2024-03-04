-- Question: Where are the top 10 longest trips in the past 3 hours?
DROP MATERIALIZED VIEW IF EXISTS longest_trips;
CREATE MATERIALIZED VIEW longest_trips AS
SELECT
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    taxi_zone_pu.Zone as pickup_zone,
    taxi_zone_do.Zone as dropoff_zone,
    trip_distance
FROM
    trip_data
        JOIN taxi_zone as taxi_zone_pu
             ON trip_data.PULocationID = taxi_zone_pu.location_id
        JOIN taxi_zone as taxi_zone_do
             ON trip_data.DOLocationID = taxi_zone_do.location_id
ORDER BY
    trip_distance DESC
    LIMIT 10;

DROP MATERIALIZED VIEW IF EXISTS longest_trips_3hr;
-- Question: Where are the top 10 longest trips in the past 3 hours?
CREATE MATERIALIZED VIEW longest_trips_3hr AS
    SELECT
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        taxi_zone_pu.Zone as pickup_zone,
        taxi_zone_do.Zone as dropoff_zone,
        trip_distance
    FROM
        trip_data
    JOIN taxi_zone as taxi_zone_pu
        ON trip_data.PULocationID = taxi_zone_pu.location_id
    JOIN taxi_zone as taxi_zone_do
        ON trip_data.DOLocationID = taxi_zone_do.location_id
    WHERE
        trip_data.tpep_pickup_datetime > (NOW() - INTERVAL '3' HOUR)
    ORDER BY
        trip_distance DESC
    LIMIT 10;