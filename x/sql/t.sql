select
  pattern_id,
  stop_sequence,
  ptn.feed_id,
  trip_id,
  arrival_time,
  departure_time,
  ptn.stop_id,
  stop_headsign,
  pickup_time,
  drop_off_type,
  route_name,
  stop_name,
  ptn.stop_headsign,
  zone_id
from stop_patterns as ptn
inner join stop_times using(pattern_id, stop_sequence)
where (pattern_id, stop_sequence) in ((1,1))
limit 100;
