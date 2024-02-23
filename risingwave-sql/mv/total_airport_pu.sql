-- Get the total ride counts for all airports.
CREATE MATERIALIZED VIEW total_airport_pu AS
    SELECT
        count(*) AS cnt,
        taxi_zone.Zone
    FROM
        trip_data
    JOIN taxi_zone
        ON trip_data.PULocationID = taxi_zone.location_id
    WHERE
        taxi_zone.Zone = 'JFK Airport'
        OR taxi_zone.Zone = 'LaGuardia Airport'
   GROUP BY taxi_zone.Zone;