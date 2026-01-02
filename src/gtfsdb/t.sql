select json_group_array(json(obj))
from (
select
  json_object(
    'feed_id', ptn.feed_id,
    'trip_ids', json_group_array(trip_id)
  ) as obj
from stop_patterns as ptn
inner join trips using(pattern_id)
inner join calendar using(feed_id, service_id)
where 
  (pattern_id, stop_sequence) in ((1,1),(2,1),(3,1), (600,1)) and
  date='2025-12-23'
group by ptn.feed_id
);
select * from trips where feed_id = 2 limit 10;