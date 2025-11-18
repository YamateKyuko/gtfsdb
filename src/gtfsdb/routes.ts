import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  enty: {
    feed_id: 'number',
    route_id: 'string',
  },
  endpoint: 'gtfsdb/routes',

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      route_id: routeId
    } = reqObj;

    const { results } = await db.prepare(`
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
  ) as obj
from stop_patterns as ptn
WHERE 
  feed_id = $1 and
  route_id = $2
group by station_id
limit 1;`,
    )
      .bind(...[feedId, routeId])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(JSON.parse(results[0].obj as string));
  },
});

export default api;