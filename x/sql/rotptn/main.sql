create schema if not exists rots;
drop table if exists rots.edges;

create table rots.edges (
  pattern_id integer,
  feed_id integer,
  route_id text,
  stop_id text,
  station_id integer,
  stop_sequence integer,
  next_stop_id text,
  next_station_id integer,
  next_stop_sequence integer
);

drop table if exists rots.indeg;
create table rots.indeg (
  station_id integer,
  deg integer
);

drop table if exists rots.results;
create table rots.results (
  feed_id integer,
  route_id text,
  station_id integer,
  next_stations integer[],
  id integer generated always as identity
  -- after_id integer
  -- station_id integer,
  -- next_station_id integer,
  -- patterns integer[]
);

do $$
declare
  rot record;
  curr_station_id integer;
  edg record;
  arr integer[];
  e record;
begin
  for rot in (select * from routes where route_name = '調３４') loop
    raise notice '%', rot.route_id;
    insert into rots.edges 
    select
      pattern_id,
      p.feed_id,
      p.route_id,
      s.stop_id,
      s.station_id,
      p.stop_sequence,
      ns.stop_id as next_stop_id,
      ns.station_id as next_station_id,
      case direction_id when 1 then p.stop_sequence - 1 else p.stop_sequence + 1 end as next_stop_sequence
    from stop_patterns as p
    inner join stops as s on
      p.feed_id = s.feed_id and
      (case direction_id when 1 then p.next_stop_id else p.stop_id end) = s.stop_id
    inner join stops as ns on
      p.feed_id = ns.feed_id and
      (case direction_id when 1 then p.stop_id else p.next_stop_id end) = ns.stop_id
    where rot.feed_id = p.feed_id and rot.route_id = p.route_id;

    insert into rots.indeg (station_id, deg)
    select n.station_id, coalesce(d.deg,0)
    from (
      select station_id as station_id from rots.edges group by station_id
      union
      select next_station_id as station_id from rots.edges group by next_station_id
    ) n
    left join (
      select next_station_id as station_id, count(*) as deg from rots.edges group by next_station_id
    ) d using (station_id);
    


    loop
      select station_id into curr_station_id
      from rots.indeg
      where deg = 0
      order by station_id desc
      limit 1;

      exit when not found;

      insert into rots.results (station_id) values (curr_station_id);

      update rots.indeg set deg = indeg.deg - sub.c
      from (
        select
          next_station_id as t,
          count(*) as c
        from rots.edges
        where station_id = curr_station_id
        group by next_station_id
      ) as sub
      where indeg.station_id = sub.t;

      delete from rots.edges where station_id = curr_station_id;
      delete from rots.indeg where station_id = curr_station_id;

    end loop;

    for curr_station_id in (select station_id from rots.indeg order by station_id) loop
      insert into rots.results (station_id) values (curr_station_id);
    end loop;
  end loop;
end;
$$ language plpgsql;
-- select * from stop_patterns;
-- select results.*, station_name from rots.results inner join parent_stations using (station_id);

select id, rots.results.station_id, station_name from rots.results inner join parent_stations using(station_id) order by id;
drop schema rots cascade;
