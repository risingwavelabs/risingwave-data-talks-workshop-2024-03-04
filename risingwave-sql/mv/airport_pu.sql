CREATE MATERIALIZED VIEW airport_pu AS
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
    SELECT count(*) as cnt, tpep_pickup_datetime as max_time
       FROM trip_data
       JOIN taxi_zone
         ON trip_data.PULocationID = taxi_zone.location_id
       , max_time_t
         WHERE taxi_zone.Borough = 'Queens'
            AND taxi_zone.Zone >= 'JFK Airport'
            AND trip_data.tpep_pickup_datetime >= ( max_time_t.max_time - INTERVAL '1' HOUR )
    GROUP BY tpep_pickup_datetime;

