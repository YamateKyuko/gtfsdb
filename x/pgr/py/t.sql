-- spacing 5m の例（投影 3857 を使って translate）
with s as (
  select s.segment_id, st_transform(s.geom,3857) as g3857
  from tmp.segments s
)
select json_build_object(
  'type','FeatureCollection',
  'features', json_agg(
    json_build_object(
      'type','Feature',
      'properties', json_build_object('segment_id', sl.segment_id, 'route_id', sl.route_id, 'lane', sl.lane),
      'geometry', st_asgeojson(st_transform(st_translate(s.g3857, (sl.lane - 2)*5, 0),4326))::json
    )
  )
) as fc
from tmp.segment_lanes sl
join s on s.segment_id = sl.segment_id;