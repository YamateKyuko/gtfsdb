import { dbAPI } from "../dbAPI";

const api = new dbAPI<{
  pattern_id: number;
  date: string; // yyyy-mm-dd
}>({
  endpoint: 'gtfsdb/dia_times',

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      pattern_id: patternId,
      date
    } = reqObj;

    const { results } = await db.prepare(`
      select 
        json_group_array(
          json_object(
            'feed_id', feed_id,
            'trip_id', trip_id,
            'stop_sequence', stop_sequence,
            'stop_id', tim.stop_id,
            'arrival_time', arrival_time,
            'departure_time', departure_time,
            'pickup_type', pickup_type,
            'drop_off_type', drop_off_type,
            'platform_code', platform_code,
            'offset_time', offset_time
          )
        )
      from stop_times as tim
      inner join stop_patterns using (feed_id, pattern_id, stop_sequence)
      inner join trips using (feed_id, trip_id)
      WHERE 
        tim.pattern_id = $1 and
        service_id in (select service_id from calendar where date = $2)
      group by trip_id
      order by
        feed_id,
        trip_id,
        stop_sequence;
      `,
    )
      .bind([patternId, date])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;