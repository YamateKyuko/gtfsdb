import { dbAPI } from "./dbAPI";

const api = new dbAPI<{
  feed_id: number;
  trip_id: string[];
  stop_id: string[];
}>({
  endpoint: 'gtfsdb/stop_patterns',

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      trip_id: tripIds,
      stop_id: stopIds
    } = reqObj;

    const { results } = await db.prepare(`
      select
        stop_patterns.feed_id,
        trips.trip_id,
        stop_patterns.pattern_id,
        stop_patterns.route_name,
        stop_patterns.route_type,
        stop_patterns.stop_sequence,
        stop_patterns.stop_id,
        stop_patterns.stop_name,
        stop_patterns.stop_headsign,
        stop_patterns.platform_code
      from trips
      inner join stop_patterns using(feed_id, pattern_id)
      where
        trips.feed_id = $1 and
        (trips.trip_id, stop_patterns.stop_id) in (${tripIds.map((s, i) => `(?${i + 2}, ?${i + tripIds.length + 2})`).join(', ')})
      `
    )
      .bind(...[feedId, ...tripIds, ...stopIds])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;