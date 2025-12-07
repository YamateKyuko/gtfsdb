-- select * from stop_patterns where pattern_id = 1 and stop_sequence = 1;








select
  pattern_id,
  ptn.feed_id,
  route_id,
  route_name,
  trip_id,
  stop_sequence,
  ptn.stop_id,
  stop_name,
  ptn.stop_headsign,
  arrival_time,
  departure_time,
  pickup_type,
  drop_off_type,
  zone_id
from stop_patterns as ptn
inner join stop_times as tim using(pattern_id, stop_sequence)
where (pattern_id, stop_sequence) in ((1,1))
limit 100;
