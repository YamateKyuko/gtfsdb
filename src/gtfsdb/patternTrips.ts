import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  endpoint: 'gtfsdb/pattern_trips',

  enty: {
    date: 'string', // 'YYYY-MM-DD'
    pattern_ids: 'number[]',
    stop_sequences: 'number[]',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      date: date,
      pattern_ids: pattern_ids,
      stop_sequences: stop_sequences
    } = reqObj;

    const { results } = await db
      .prepare(`
select json_group_array(json(obj)) as obj
from (
select
  json_object(
    'feed_id', ptn.feed_id,
    'trip_ids', json_group_array(trip_id)
  ) as obj
from stop_patterns as ptn
inner join trips using(pattern_id)
inner join calendar using(feed_id, service_id)
where 
  (ptn.pattern_id, ptn.stop_sequence) in (${pattern_ids.map((v, i) => `(?${i + 1 + 1}, ?${pattern_ids.length + i + 1 + 1})`).join(', ')}) and
  date = ?1
group by ptn.feed_id
      `)
      .bind(...[date, ...pattern_ids, ...stop_sequences])
      .all();
    
    if (!results) return Response.json([]);
    
    return Response.json(JSON.parse(results[0].obj as string));
  },
});

export default api;