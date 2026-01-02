import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  enty: {
    station_id: 'number',
  },
  endpoint: 'gtfsdb/stations',

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      station_id: stationId
    } = reqObj;

    const { results } = await db.prepare(`
select 
  json_object(
    'station_name', station_name,
    'station_id', station_id,
    'station_lat', station_lat,
    'station_lon', station_lon,
    'stop_patterns', json_group_array(
      json_object(
        'feed_id', stops.feed_id,
        'stop_id', stop_id,
        'stop_name', stops.stop_name,
        'pattern_id', spt.pattern_id,
        'route_id', spt.route_id,
        'stop_sequence', stop_sequence,
        'direction_id', spt.direction_id,
        'route_name', spt.route_name,
        'stop_headsign', stop_headsign,
        'platform_code', spt.platform_code,
        'zone_id', spt.zone_id,
        'first_stop_name', first_stop_name,
        'weekday_count', cnt
      ) order by stop_id, stops.feed_id, spt.route_id, cnt desc
    )
  ) as obj
from parent_stations, (select '平' as daytype)
left join stops using(station_id)
left join stop_patterns as spt using (feed_id, stop_id)
left join trip_patterns as tpt using (pattern_id)
left join daytype_cnt as cnt using (pattern_id, daytype)
WHERE 
  station_id = ?1 and
  location_type != 1
;`,
    )
      .bind(...[stationId])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(JSON.parse(results[0].obj as string));
  },
});

export default api;

// select 
//   json_build_object(
//     'station_name', station_name,
//     'station_id', station_id,
//     'station_lat', station_lat,
//     'station_lon', station_lon,
//     'stop_patterns', json_agg(
//       json_build_object(
//         'feed_id', stp.feed_id,
//         'stop_id', stp.stop_id,
//         'stop_name', stp.stop_name,
//         'pattern_id', pattern_id,
//         'route_id', route_id,
//         'stop_sequence', stop_sequence,
//         'direction_id', direction_id,
//         'route_name', route_name,
//         'stop_headsign', stop_headsign,
//         'stop_name_translation', coalesce(snt.translation, stp.stop_name),
//         'route_name_translation', coalesce(rnt.translation, ptn.route_name)
//       )
//     )
//   ) as obj
// from parent_stations as sta
// inner join stops as stp using(station_id)
// inner join stop_patterns as ptn using (feed_id, stop_id)
// left join stop_name_translations as snt on (
//     (stp.feed_id = snt.feed_id and stp.stop_id = snt.stop_id) or
//     (stp.feed_id = snt.feed_id and stp.stop_name = snt.stop_name)) and
//   language = 'en'
// left join route_short_name_translations as rnt on (
//     (stp.feed_id = rnt.feed_id and ptn.route_id = rnt.route_id) or
//     (stp.feed_id = rnt.feed_id and ptn.route_name = rnt.route_name)) and
//   language = 'en'
// WHERE 
//   station_id = 1
// group by station_id;