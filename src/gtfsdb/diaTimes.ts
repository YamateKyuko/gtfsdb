import { dbAPI } from "../gtfsdbAPI";

const api = new dbAPI({
  endpoint: 'gtfsdb/dia_times',

  enty: {
    pattern_id: 'number',
    date: 'string',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      pattern_id: patternId,
      date
    } = reqObj;

    const { results } = await db.prepare(`
with trps as (
  select 
    json_object(
      'feed_id', feed_id,
      'trip_id', trip_id,
      'stop_times', json_group_array(
        json_object(
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
    ) as trp
  from stop_times as tim
  inner join stop_patterns using (feed_id, pattern_id, stop_sequence)
  inner join trips using (feed_id, trip_id)
  WHERE 
    tim.pattern_id = $1 and
    service_id in (select service_id from calendar where date = $2)
  group by feed_id, trip_id
  order by
    feed_id,
    trip_id,
    stop_sequence
),
ptns as (
  select
    json_object(
      'feed_id', feed_id,
      'pattern_id', pattern_id,
      'route_id', route_id,
      'route_name', route_name,
      'route_type', route_type,
      'stop_sequence', stop_sequence,
      'stop_id', stop_id,
      'stop_name', stop_name,
      'stop_headsign', stop_headsign,
      'offset_time', ifnull(offset_time, 0),
      'platform_code', platform_code
    ) as ptn
  from stop_patterns
  where pattern_id = $1
)
select
  json_object(
    'patterns', (select json_group_array(json(ptn)) from ptns),
    'trips', (select json_group_array(json(trp)) from trps)
  ) as obj;

      `,
    )
      .bind(...[patternId, date])
      .all()
      ;
    
    if (!results) return Response.json([]);
    
    return Response.json(JSON.parse(results[0].obj as string));
  },
});

export default api;


// 多次元配列諦め




// feed_id: number,
// route_id: string,
// route_name: string,
// route_type: number,
// stop_sequence: number,
// stop_name: string,
// stop_headsign: string | null,
// offset_time: number,