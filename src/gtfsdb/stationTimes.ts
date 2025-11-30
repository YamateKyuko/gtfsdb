import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  endpoint: 'gtfsdb/station_times',
  enty: {
    feed_id: 'number',
    station_id: 'number',
    next_station_id: 'number',
    route_id: 'string',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      station_id: stationId,
      next_station_id: nextStationId,
      route_id: routeId
    } = reqObj;

    const { results } = await db.prepare(`
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
where
  p.feed_id = $1 and
  p.route_id = $4 and
  (p.feed_id, p.stop_id) in (select feed_id, stop_id from stops where station_id = $2) and
  (p.feed_id, p.next_stop_id) in (select feed_id, stop_id from stops where station_id = $3);
  `)
      .bind(...[feedId, stationId, nextStationId, routeId])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;