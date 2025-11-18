import { dbAPI } from "../gtfsdbAPI";

// <{
//   feed_id: number;
//   trip_id: string;
// }>
const api = new dbAPI({
  endpoint: 'gtfsdb/stop_times',
  enty: {
    feed_id: 'number',
    trip_id: 'string',
    stop_sequence: 'number | null',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      trip_id: tripId,
      stop_sequence: stopSequence
    } = reqObj;

    let res;

    if (!stopSequence) {
      res = await db.prepare(`
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
    } else {
      res = await db.prepare(`
with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = $1 and trip_id = $2 and stop_sequence = $3),
fare_rule as (select fare_rules.* from trips inner join routes using(feed_id, route_id) inner join fare_rules using(feed_id, route_id) where feed_id = $1 and trip_id = $2 group by fare_rules.feed_id, fare_rules.route_id, fare_id, origin_id, destination_id)
SELECT 
  stop_times.feed_id,
  trip_id,
  stop_sequence,
  stop_id,
  arrival_time,
  departure_time,
  stop_headsign,
  pickup_type,
  drop_off_type,
  stop_name,
  platform_code,
  price
FROM stop_times

inner join stops using (feed_id, stop_id)
inner join trips using (feed_id, trip_id)
inner join curr_zone_id on true
left join fare_rule as fare_rules on (
  -- stop_times.feed_id = fare_rules.feed_id and
  -- trips.route_id = fare_rules.route_id and
  ((
    fare_rules.origin_id is null and
    fare_rules.destination_id is null and
    stop_times.stop_sequence != $3
  ) or (
    stop_times.stop_sequence < $3 and (
      fare_rules.origin_id = stops.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    stop_times.stop_sequence > $3 and (
      fare_rules.destination_id = stops.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
  ))
)
left join fare_attributes on (
  stop_times.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
WHERE stop_times.feed_id = $1 and stop_times.trip_id = $2
order by stop_sequence;
        `
      )
        .bind(...[feedId, tripId, stopSequence])
        .all();
    }

    const { results } = res;
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;