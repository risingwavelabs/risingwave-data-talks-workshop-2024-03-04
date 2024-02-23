-- Get the latest 1 hour pickup count from JFK airport in Queens.
-- Break it down
CREATE MATERIALIZED VIEW airport_pu_1hr AS
WITH max_time_t AS (
    SELECT
        max(tpep_pickup_datetime) AS max_time
    FROM
        trip_data
        JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
    WHERE
        taxi_zone.Borough = 'Queens'
        AND taxi_zone.Zone >= 'JFK Airport'
)
SELECT
    count(*) AS cnt,
    tpep_pickup_datetime AS max_time
FROM
    trip_data
    JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id,
    max_time_t
WHERE
    taxi_zone.Borough = 'Queens'
    AND taxi_zone.Zone >= 'JFK Airport'
    AND trip_data.tpep_pickup_datetime >= (max_time_t.max_time - INTERVAL '1' HOUR)
GROUP BY
    tpep_pickup_datetime;

