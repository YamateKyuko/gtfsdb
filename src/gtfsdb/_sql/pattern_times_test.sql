-- .600
-- Query Time: 775.6ms Response Time: 1.55s Rows Read: 521985
-- Query Time: 0.4ms Response Time: 607.0ms Rows Read: 19
select
  ptn.pattern_id,
  ptn.feed_id,
  trp.route_id,
  -- route_name,
  trip_id,
  stop_sequence,
  ptn.stop_id,
  -- stop_name,
  ptn.stop_headsign,
  arrival_time,
  departure_time,
  pickup_type,
  drop_off_type
  -- zone_id
from stop_patterns as ptn
inner join trips as trp using(pattern_id)
-- from trips as trp
inner join stop_times using(feed_id, trip_id, stop_sequence)
where (ptn.pattern_id, ptn.stop_sequence) in ((1,1))
order by arrival_time asc;

-- Query Time: 2.3ms Response Time: 644.0ms Rows Read: 18
select
  trp.pattern_id,
  trp.feed_id,
  trp.route_id,
  -- route_name,
  trip_id,
  stop_sequence,
  stop_id,
  -- stop_name,
  stop_headsign,
  arrival_time,
  departure_time,
  pickup_type,
  drop_off_type
  -- zone_id

-- from stop_patterns as ptn
-- inner join trips as trp using(pattern_id)
from trips as trp
inner join stop_times using(feed_id, trip_id)
where (trp.pattern_id, stop_sequence) in ((1,1))
order by arrival_time asc;