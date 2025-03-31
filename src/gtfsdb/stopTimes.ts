import { dbAPI } from "./dbAPI";

const api = new dbAPI<{
  feed_id: number;
  trip_id: string;
}>({
  endpoint: 'gtfsdb/stop_times',

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      trip_id: tripId
    } = reqObj;

    const { results } = await db.prepare(`
      SELECT 
        feed_id,
        trip_id,
        stop_sequence,
        stop_id,
        arrival_time,
        departure_time,
        stop_headsign,
        pickup_type,
        drop_off_type,
        stop_name,
        platform_code
      FROM stop_times
      inner join stops using (feed_id, stop_id)
      WHERE feed_id = $1 and trip_id = $2
      
      order by stop_sequence
      `,
    )
      .bind(...[feedId, tripId])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;