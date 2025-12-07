import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  endpoint: 'gtfsdb/pattern_times',

  enty: {
    pattern_id: 'number[]',
    stop_sequence: 'number[]',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      pattern_id: pattern_ids,
      stop_sequence: stop_sequences
    } = reqObj;

    const { results } = await db
      .prepare(`
select
  pattern_id,
  ptn.feed_id,
  route_id,
  route_name,
  trip_id,
  stop_sequence,
  ptn.stop_id,
  stop_name,
  ptn.stop_headsign,
  arrival_time,
  departure_time,
  pickup_type,
  drop_off_type,
  zone_id
from stop_patterns as ptn
inner join stop_times using(pattern_id, stop_sequence)
where (pattern_id, stop_sequence) in (${pattern_ids.map(() => '(?, ?)').join(', ')})
limit 1;
      `)
      .bind(...[...pattern_ids, ...stop_sequences])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;
