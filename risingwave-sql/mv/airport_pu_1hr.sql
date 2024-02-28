-- Question:
-- From 1 hour before the last pickup time, how many pickups are there from JFK airport in Queens?
-- First, we construct a simpler MV, get all pickups from JFK airport in Queens
CREATE MATERIALIZED VIEW airport_pu as SELECT
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
GROUP BY
    tpep_pickup_datetime;

-- Next, we also want to add a filter, to get all pickups from 1 hr before:
-- We just use a fixed time first.
CREATE MATERIALIZED VIEW airport_pu_1hr_const as SELECT
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
  AND trip_data.tpep_pickup_datetime >= (TIMESTAMP '2024-02-01 00:00:00' - INTERVAL '1' HOUR)
GROUP BY
    tpep_pickup_datetime;

-- How can we track the latest time?
CREATE MATERIALIZED_VIEW latest_pickup_time
    SELECT
        max(tpep_pickup_datetime) AS max_time
    FROM
        trip_data
            JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
    WHERE
            taxi_zone.Borough = 'Queens'
      AND taxi_zone.Zone >= 'JFK Airport';

-- Finally we put it all together
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

