-- select
--   spt.feed_id,
--   trp.trip_id,
--   spt.pattern_id,
--   spt.route_name,
--   spt.route_type,
--   spt.stop_sequence,
--   spt.stop_id,
--   spt.stop_name,
--   spt.stop_headsign,
--   spt.platform_code,
--   trp.trip_headsign,
--   coalesce(snt.translation, spt.stop_name) as stop_name_translation,
--   coalesce(rnt.translation, spt.route_name) as route_name_translation,
--   coalesce(sht.stop_headsign, spt.stop_headsign) as stop_headsign_translation
-- from trips as trp
-- inner join stop_patterns as spt using(feed_id, pattern_id)
-- left join stop_name_translations as snt on (
--   (trp.feed_id = snt.feed_id and spt.stop_id = snt.stop_id) or
--   (trp.feed_id = snt.feed_id and spt.stop_name = snt.stop_name)) and
--   snt.language = 'en'
-- left join route_short_name_translations as rnt on (
--   (trp.feed_id = rnt.feed_id and spt.route_id = rnt.route_id) or
--   (trp.feed_id = rnt.feed_id and spt.route_name = rnt.route_short_name)) and
--   rnt.language = 'en'
-- left join stop_headsign_translations as sht on (
--   (trp.feed_id = sht.feed_id and trp.trip_id = sht.trip_id and spt.stop_sequence = sht.stop_sequence) or
--   (trp.feed_id = sht.feed_id and spt.stop_headsign = sht.stop_headsign)) and
--   sht.language = 'en'
-- where
--   trp.feed_id = 1 and
--   (trp.trip_id, spt.stop_id) in (('06_02_0631_03_004431', '0070_01'));

-- SELECT 
--   tim.feed_id,
--   tim.trip_id,
--   tim.stop_sequence,
--   tim.stop_id,
--   tim.arrival_time,
--   tim.departure_time,
--   tim.stop_headsign,
--   pickup_type,
--   drop_off_type,
--   stp.stop_name,
--   platform_code,
--   coalesce(snt.translation, stp.stop_name) as stop_name_translation
-- FROM stop_times as tim
-- inner join stops as stp using (feed_id, stop_id)
-- left join stop_name_translations as snt on (
--   (tim.feed_id = snt.feed_id and tim.stop_id = snt.stop_id) or
--   (tim.feed_id = snt.feed_id and stp.stop_name = snt.stop_name)) and
--   snt.language = 'en'
-- left join stop_headsign_translations as sht on (
--   (tim.feed_id = sht.feed_id and tim.trip_id = sht.trip_id and tim.stop_sequence = sht.stop_sequence) or
--   (tim.feed_id = sht.feed_id and tim.stop_headsign = sht.stop_headsign)) and
--   sht.language = 'en'
-- WHERE tim.feed_id = 1 and tim.trip_id = '06_02_0631_03_004431'
-- order by stop_sequence

-- select * from stop_headsign_translations limit 100;

with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = 1 and trip_id = '06_02_0631_03_004431' and stop_sequence = 5),
fare_rule as (select fare_rules.* from trips inner join routes using(feed_id, route_id) inner join fare_rules using(feed_id, route_id) where feed_id = 1 and trip_id = '06_02_0631_03_004431' group by fare_rules.feed_id, fare_rules.route_id, fare_id, origin_id, destination_id)
SELECT 
  tim.feed_id,
  tim.trip_id,
  tim.stop_sequence,
  tim.stop_id,
  tim.arrival_time,
  tim.departure_time,
  tim.stop_headsign,
  pickup_type,
  drop_off_type,
  stp.stop_name,
  platform_code,
  price,
  coalesce(snt.translation, stp.stop_name) as stop_name_translation,
  coalesce(sht.translation, tim.stop_headsign) as stop_headsign_translation
FROM stop_times as tim
inner join stops as stp using (feed_id, stop_id)
inner join trips using (feed_id, trip_id)
inner join curr_zone_id on true
left join fare_rule as fare_rules on (((
    fare_rules.origin_id is null and
    fare_rules.destination_id is null and
    tim.stop_sequence != 5
  ) or (
    tim.stop_sequence < 5 and (
      fare_rules.origin_id = stp.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    tim.stop_sequence > 5 and (
      fare_rules.destination_id = stp.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
)))
left join fare_attributes on (
  tim.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
left join stop_name_translations as snt on (
  (tim.feed_id = snt.feed_id and tim.stop_id = snt.stop_id) or
  (tim.feed_id = snt.feed_id and stp.stop_name = snt.stop_name)) and
  snt.language = 'en'
left join stop_headsign_translations as sht on (
  (tim.feed_id = sht.feed_id and tim.trip_id = sht.trip_id and tim.stop_sequence = sht.stop_sequence) or
  (tim.feed_id = sht.feed_id and tim.stop_headsign = sht.stop_headsign)) and
  sht.language = 'en'
WHERE tim.feed_id = 1 and tim.trip_id = '06_02_0631_03_004431'
order by stop_sequence;