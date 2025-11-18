select * from fare_rules where feed_id = 1 and route_id = '365';
-- origin_id = 'Z1720_00' and destination_id = 'Z0315_02';
-- with trip as (select * from trips inner join routes)
with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = 1 and trip_id = '05_01_5032_03_016482' and stop_sequence = 16),
fare_rule as (select fare_rules.* from trips inner join routes using(feed_id, route_id) inner join fare_rules using(feed_id, route_id) where feed_id = 1 and trip_id = '05_01_5032_03_016482' group by fare_rules.feed_id, fare_rules.route_id, fare_id, origin_id, destination_id)
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
left join fare_rule as fare_rules on (
  -- stop_times.feed_id = fare_rules.feed_id and
  -- trips.route_id = fare_rules.route_id and
  ((
    fare_rules.origin_id is null and
    fare_rules.destination_id is null and
    stop_times.stop_sequence != 16
  ) or (
    stop_times.stop_sequence < 16 and (
      fare_rules.origin_id = stops.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    stop_times.stop_sequence > 16 and (
      fare_rules.destination_id = stops.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
  ))
)
left join fare_attributes on (
  stop_times.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
WHERE stop_times.feed_id = 1 and stop_times.trip_id = '05_01_5032_03_016482'
order by stop_sequence;

    -- feed_id: 1,
    -- trip_id: '05_01_5032_03_016482',
    -- stop_sequence: 16,
    -- stop_id: '0315_02',
    -- arrival_time: 42180,
    -- departure_time: 42180,
    -- stop_headsign: '調布駅南口',
    -- pickup_type: 0,
    -- drop_off_type: 0,
    -- stop_name: '京王多摩川駅',
    -- platform_code: '2',
    -- price: null