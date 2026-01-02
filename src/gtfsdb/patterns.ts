import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  endpoint: 'gtfsdb/patterns',

  enty: {
    pattern_ids: 'number[]',
    stop_sequences: 'number[]',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      pattern_ids: pattern_ids,
      stop_sequences: stop_sequences
    } = reqObj;

    const { results } = await db
      .prepare(`
select
  pattern_id,
  ptn.feed_id,
  ptn.route_id,
  ptn.route_name,
  stop_sequence,
  ptn.stop_id,
  stop_name,
  ptn.stop_headsign,
  zone_id,
  first_stop_name
from stop_patterns as ptn
inner join trip_patterns using(pattern_id)
where (pattern_id, stop_sequence) in (${pattern_ids.map((v, i) => `(?${i + 1}, ?${pattern_ids.length + i + 1})`).join(', ')})
order by pattern_id, stop_sequence;
      `)
      .bind(...[...pattern_ids, ...stop_sequences])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;