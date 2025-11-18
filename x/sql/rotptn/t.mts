import { Client } from 'pg';
import dotenv from 'dotenv'

const cwd = process.cwd();
dotenv.config({ path: `${cwd}/.env.db.local`, quiet: true });


async function main() {
  const client = new Client(process.env.DATABASE_URL_LOCAL);
  await client.connect();
  console.log('aa');

  const res = await client.query(`
    with paths as (
      select
        pattern_id,
        p.feed_id,
        p.route_id,
        p.stop_sequence,
        s.stop_id,
        s.station_id,
        case direction_id when 1 then p.stop_sequence - 1 else p.stop_sequence + 1 end as next_stop_sequence,
        ns.stop_id as next_stop_id,
        ns.station_id as next_station_id
      from stop_patterns as p
      inner join stops as s on
        p.feed_id = s.feed_id and
        (case direction_id when 1 then p.next_stop_id else p.stop_id end) = s.stop_id
      inner join stops as ns on
        p.feed_id = ns.feed_id and
        (case direction_id when 1 then p.stop_id else p.next_stop_id end) = ns.stop_id
      -- where rot.feed_id = p.feed_id and rot.route_id = p.route_id
      where route_name = '武７３'
    )
    select
      station_id,
      json_agg(json_object(
        'pattern_id': pattern_id,
        'stop_sequence': stop_sequence,
        'station_id': station_id,
        'next_stop_sequence': next_stop_sequence,
        'next_station_id': next_station_id
      )) as patterns
    from paths
    group by station_id;
  `, []);

  

  await client.end();

  type sta = {
    station_id: number;
    patterns: {
      pattern_id: number
      stop_sequence: number;
      next_stop_sequence: number;
      next_station_id: number;
    }[];
  };

  const obj = res.rows as sta[];
  console.log(res.rows);
  for (let i = 0; i < obj.length; i++) {
    
  }

}

main();