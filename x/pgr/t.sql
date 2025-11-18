select 
  json_object(
    'feed_id': feed_id,
    'route_id': route_id,
    'route_name': route_name,
    -- 'route_desc': route_desc,
    
    'route_type': route_type
    -- 'stop_patterns', json_group_array(
    --   json_object(
    --     'feed_id', feed_id,
    --     'pattern_id', pattern_id,
    --     'route_id', route_id,
    --     'stop_sequence', stop_sequence,
    --     'direction_id', direction_id,
    --     'route_name', route_name
    --   )
    -- )
  ) as obj
from stop_patterns as ptn
WHERE 
  feed_id = 1 and
  route_id = '452'
  -- pattern_id in (412, 413)
limit 1;

-- select * from stop_patterns where route_name = '武７３' order by pattern_id, stop_sequence;