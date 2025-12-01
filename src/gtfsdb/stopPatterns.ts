import { dbAPI } from "../gtfsdbAPI";

// <{
//   feed_id: number;
//   trip_id: string[];
//   stop_id: string[];
// }>
const api = new dbAPI({
  endpoint: 'gtfsdb/stop_patterns',
  enty: {
    feed_id: 'number',
    trip_id: 'string[]',
    stop_id: 'string[]',
    lang: '?string',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      trip_id: tripIds,
      stop_id: stopIds,
      lang: lang,
    } = reqObj;

    let res;

    if (lang) {
      res = await db
        .prepare(stopPatternsLangdQuery(tripIds.map((s, i) => `(?${i + 3}, ?${i + tripIds.length + 3})`).join(', ')))
        .bind(...[feedId, lang, ...tripIds, ...stopIds])
        .all();
    } else {
      res = await db
        .prepare(stopPatternsQuery(tripIds.map((s, i) => `(?${i + 2}, ?${i + tripIds.length + 2})`).join(', ')))
        .bind(...[feedId, ...tripIds, ...stopIds])
        .all();
    };

    const results = res.results;
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;

const stopPatternsLangdQuery = (temps1: string) => `
select
  spt.feed_id,
  trp.trip_id,
  spt.pattern_id,
  spt.route_name,
  spt.route_type,
  spt.stop_sequence,
  spt.stop_id,
  spt.stop_name,
  spt.stop_headsign,
  spt.platform_code,
  trp.trip_headsign,
  coalesce(snt.translation, spt.stop_name) as stop_name_translation,
  coalesce(rnt.translation, spt.route_name) as route_name_translation,
  coalesce(sht.translation, spt.stop_headsign) as stop_headsign_translation
from trips as trp
inner join stop_patterns as spt using(feed_id, pattern_id)
left join stop_name_translations as snt on (
  (trp.feed_id = snt.feed_id and spt.stop_id = snt.stop_id) or
  (trp.feed_id = snt.feed_id and spt.stop_name = snt.stop_name)) and
  snt.language = ?2
left join route_short_name_translations as rnt on (
  (trp.feed_id = rnt.feed_id and spt.route_id = rnt.route_id) or
  (trp.feed_id = rnt.feed_id and spt.route_name = rnt.route_short_name)) and
  rnt.language = ?2
left join stop_headsign_translations as sht on (
  (trp.feed_id = sht.feed_id and trp.trip_id = sht.trip_id and spt.stop_sequence = sht.stop_sequence) or
  (trp.feed_id = sht.feed_id and spt.stop_headsign = sht.stop_headsign)) and
  sht.language = ?2
where
    trp.feed_id = ?1 and
    (trp.trip_id, spt.stop_id) in (${temps1});`;

const stopPatternsQuery = (temps1: string) => `
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
  trips.feed_id = ?1 and
  (trips.trip_id, stop_patterns.stop_id) in (${temps1});
`;