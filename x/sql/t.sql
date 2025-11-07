with stps as (
  select 
    json_object(
      'feed_id', feed_id,
      'stop_id', stop_id,
      'stop_name', ptn.stop_name,
      'station_id', station_id,
      'stop_desc', stop_desc,
      'stop_lat', stop_lat,
      'stop_lon', stop_lon,
      'stop_patterns', json_group_array(
        json_object(
          'feed_id', feed_id,
          'pattern_id', pattern_id,
          'route_id', route_id,
          'stop_sequence', stop_sequence,
          'direction_id', direction_id,
          'route_name', route_name
        )
      )
    ) as sta
  from stop_patterns as ptn
  inner join stops using (feed_id, stop_id)
  WHERE 
    station_id = 1
  group by station_id
)
select
  sta as obj
  from parent_stations;