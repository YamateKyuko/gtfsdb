



-- select * from stop_times limit 1;


select 
  p.feed_id,
  p.route_id,
  p.pattern_id,
  p.stop_sequence,
  stop_times.stop_headsign,
  stop_times.arrival_time,
  stop_times.departure_time,
  trips.trip_id,
  p.stop_id,
  p.next_stop_id
from stop_patterns as p
inner join trips using(feed_id, pattern_id)
inner join stop_times using(feed_id, trip_id, stop_sequence)
-- inner join stop_times using (feed_id, stop_)
where
  p.feed_id = 1 and
  p.route_id = '443' and
  (p.feed_id, p.stop_id) in (select feed_id, stop_id from stops where station_id = 2236) and
  (p.feed_id, p.next_stop_id) in (select feed_id, stop_id from stops where station_id = 2507);