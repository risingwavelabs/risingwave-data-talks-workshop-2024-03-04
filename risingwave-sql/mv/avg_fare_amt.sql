-- Naive version:
-- avg_fare across all rides.
--
-- Question we want to answer:
-- How does avg_fare_amt change relative to number of rides per hour?
--
-- Hint:
-- Can use sliding windows to answer this question.
-- 1. Get number of rides
-- 2. Get avg_fare_amt
-- 3. Set window size to 1 hour.
CREATE MATERIALIZED VIEW avg_fare_amt AS
SELECT
    avg(fare_amount) AS avg_fare_amount_per_hour,
    count(*) AS num_rides_per_hour,
    window_start,
    window_end
FROM
    HOP(trip_data, tpep_pickup_datetime, INTERVAL '1' MINUTE , INTERVAL '1' HOUR)
GROUP BY
    window_start, window_end
ORDER BY
    num_rides_per_hour ASC;
