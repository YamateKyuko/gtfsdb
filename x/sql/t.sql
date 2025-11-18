-- select * from trips where route_id = '452';
with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = 1 and trip_id = '06_01_5091_02_011761' and stop_sequence = 5)
SELECT 
  stop_times.feed_id,
  trip_id,
  stop_sequence,
  stop_id,
  arrival_time,
  departure_time,
  stop_headsign,
  pickup_type,
  drop_off_type,
  stop_name,
  platform_code,
  price
FROM stop_times

inner join stops using (feed_id, stop_id)
inner join trips using (feed_id, trip_id)
inner join curr_zone_id on true
left join fare_rules on (
  stop_times.feed_id = fare_rules.feed_id and
  trips.route_id = fare_rules.route_id and
  (
    stop_times.stop_sequence < 5 and (
      fare_rules.origin_id = stops.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    stop_times.stop_sequence > 5 and (
      fare_rules.destination_id = stops.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
  )
)
left join fare_attributes on (
  stop_times.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
WHERE stop_times.feed_id = 1 and stop_times.trip_id = '06_01_5091_02_011761'
order by stop_sequence;