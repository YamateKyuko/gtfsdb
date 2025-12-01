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
    lang: '?string',
  },

  async getProcesor(
    reqObj,
    db: D1Database
  ) {
    const {
      feed_id: feedId,
      trip_id: tripId,
      stop_sequence: stopSequence,
      lang: lang,
    } = reqObj;

    let res;

    if (!stopSequence && !lang) {
      res = await db
        .prepare(stopTimesQuery)
        .bind(...[feedId, tripId])
        .all();
    } else if (!stopSequence && lang) {
      res = await db
        .prepare(stopTimesLangdQuery)
        .bind(...[feedId, tripId, lang])
        .all();
    } else if (stopSequence && !lang) {
      res = await db
        .prepare(stopTimesFaredQuery)
        .bind(...[feedId, tripId, stopSequence])
        .all();
    } else {
      res = await db
        .prepare(stopTimesFaredLangdQuery)
        .bind(...[feedId, tripId, stopSequence, lang])
        .all();
    }

    const { results } = res;
    
    if (!results) return Response.json([]);
    
    return Response.json(results);
  },
});

export default api;

const stopTimesQuery = `
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
WHERE feed_id = ?1 and trip_id = ?2
order by stop_sequence;
`;

const stopTimesLangdQuery = `
SELECT 
  tim.feed_id,
  tim.trip_id,
  tim.stop_sequence,
  tim.stop_id,
  tim.arrival_time,
  tim.departure_time,
  tim.stop_headsign,
  pickup_type,
  drop_off_type,
  stp.stop_name,
  platform_code,
  coalesce(snt.translation, stp.stop_name) as stop_name_translation,
  coalesce(sht.translation, tim.stop_headsign) as stop_headsign_translation
FROM stop_times as tim
inner join stops as stp using (feed_id, stop_id)
left join stop_name_translations as snt on (
  (tim.feed_id = snt.feed_id and tim.stop_id = snt.stop_id) or
  (tim.feed_id = snt.feed_id and stp.stop_name = snt.stop_name)) and
  snt.language = ?3
left join stop_headsign_translations as sht on (
  (tim.feed_id = sht.feed_id and tim.trip_id = sht.trip_id and tim.stop_sequence = sht.stop_sequence) or
  (tim.feed_id = sht.feed_id and tim.stop_headsign = sht.stop_headsign)) and
  sht.language = ?3
WHERE tim.feed_id = ?1 and tim.trip_id = ?2
order by stop_sequence;`;

const stopTimesFaredQuery = `
with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = ?1 and trip_id = ?2 and stop_sequence = ?3),
fare_rule as (select fare_rules.* from trips inner join routes using(feed_id, route_id) inner join fare_rules using(feed_id, route_id) where feed_id = ?1 and trip_id = ?2 group by fare_rules.feed_id, fare_rules.route_id, fare_id, origin_id, destination_id)
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
left join fare_rule as fare_rules on (((
    fare_rules.origin_id is null and
    fare_rules.destination_id is null and
    stop_times.stop_sequence != ?3
  ) or (
    stop_times.stop_sequence < ?3 and (
      fare_rules.origin_id = stops.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    stop_times.stop_sequence > ?3 and (
      fare_rules.destination_id = stops.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
)))
left join fare_attributes on (
  stop_times.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
WHERE stop_times.feed_id = ?1 and stop_times.trip_id = ?2
order by stop_sequence;`;

const stopTimesFaredLangdQuery = `
with curr_zone_id as (select zone_id from stop_times inner join stops using(feed_id, stop_id) where feed_id = ?1 and trip_id = ?2 and stop_sequence = ?3),
fare_rule as (select fare_rules.* from trips inner join routes using(feed_id, route_id) inner join fare_rules using(feed_id, route_id) where feed_id = ?1 and trip_id = ?2 group by fare_rules.feed_id, fare_rules.route_id, fare_id, origin_id, destination_id)
SELECT 
  tim.feed_id,
  tim.trip_id,
  tim.stop_sequence,
  tim.stop_id,
  tim.arrival_time,
  tim.departure_time,
  tim.stop_headsign,
  pickup_type,
  drop_off_type,
  stp.stop_name,
  platform_code,
  price,
  coalesce(snt.translation, stp.stop_name) as stop_name_translation,
  coalesce(sht.translation, tim.stop_headsign) as stop_headsign_translation
FROM stop_times as tim
inner join stops as stp using (feed_id, stop_id)
inner join trips using (feed_id, trip_id)
inner join curr_zone_id on true
left join fare_rule as fare_rules on (((
    fare_rules.origin_id is null and
    fare_rules.destination_id is null and
    tim.stop_sequence != ?3
  ) or (
    tim.stop_sequence < ?3 and (
      fare_rules.origin_id = stp.zone_id and
      fare_rules.destination_id = curr_zone_id.zone_id) or
    tim.stop_sequence > ?3 and (
      fare_rules.destination_id = stp.zone_id and
      fare_rules.origin_id = curr_zone_id.zone_id)
)))
left join fare_attributes on (
  tim.feed_id = fare_attributes.feed_id and
  fare_rules.fare_id = fare_attributes.fare_id
)
left join stop_name_translations as snt on (
  (tim.feed_id = snt.feed_id and tim.stop_id = snt.stop_id) or
  (tim.feed_id = snt.feed_id and stp.stop_name = snt.stop_name)) and
  snt.language = ?4
left join stop_headsign_translations as sht on (
  (tim.feed_id = sht.feed_id and tim.trip_id = sht.trip_id and tim.stop_sequence = sht.stop_sequence) or
  (tim.feed_id = sht.feed_id and tim.stop_headsign = sht.stop_headsign)) and
  sht.language = ?4
WHERE tim.feed_id = ?1 and tim.trip_id = ?2
order by stop_sequence;`;