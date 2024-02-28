-- What are the current top 10 busiest drop-off zones for the past 5min?
-- Group TopN pattern: https://docs.risingwave.com/docs/current/sql-pattern-topn/

DROP MATERIALIZED VIEW IF EXISTS busy_do_zones;

CREATE MATERIALIZED VIEW busy_do_zones AS
SELECT
    taxi_zone.Zone AS dropoff_zone,
    count(*) AS last_5_min_dropoff_cnt
FROM
    trip_data
        JOIN taxi_zone
             ON trip_data.DOLocationID = taxi_zone.location_id
GROUP BY
    taxi_zone.Zone
ORDER BY last_5_min_dropoff_cnt ASC
    LIMIT 10;

DROP MATERIALIZED VIEW IF EXISTS busy_do_zones_5min;
-- What are the current top 10 busiest drop-off zones for the past 5min?
-- Group TopN pattern: https://docs.risingwave.com/docs/current/sql-pattern-topn/
CREATE MATERIALIZED VIEW busy_do_zones_5min AS
       SELECT
           taxi_zone.Zone AS dropoff_zone,
           count(*) AS last_5_min_dropoff_cnt
       FROM
           trip_data
       JOIN taxi_zone
           ON trip_data.DOLocationID = taxi_zone.location_id
       WHERE
           trip_data.tpep_dropoff_datetime > (NOW() - INTERVAL '1' HOUR)
       GROUP BY
           taxi_zone.Zone
       ORDER BY last_5_min_dropoff_cnt ASC
       LIMIT 10;