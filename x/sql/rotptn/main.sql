create schema if not exists rots;
drop table if exists rots.edges;
create table rots.edges (
  pattern_id integer,
  feed_id integer,
  route_id text,
  stop_id text,
  station_id integer,
  next_stop_id text,
  next_station_id integer
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

drop table if exists rots.indeg;
create table rots.indeg (station_id integer, deg integer);

drop table if exists rots.rs;
create table if not exists rots.rs(
  -- feed_id integer,
  -- route_id text,
  station_id integer,
  -- next_stations integer[],
  after_id integer,
  station integer
);

do $$
declare
  rot record;
  curr_station_id integer;
  edg record;
  cnt integer;
  arr integer[];
  e record;
begin
  cnt := 0;
  for rot in (select * from routes where route_name = '武７３') loop
    raise notice '%', rot.route_id;
    insert into rots.edges
    select
      pattern_id,
      p.feed_id,
      p.route_id,
      s.stop_id,
      s.station_id,
      ns.stop_id as next_stop_id,
      ns.station_id as next_station_id
    from stop_patterns as p
    inner join stops as s on
      p.feed_id = s.feed_id and
      (case direction_id when 1 then p.next_stop_id else p.stop_id end) = s.stop_id
    inner join stops as ns on
      p.feed_id = ns.feed_id and
      (case direction_id when 1 then p.stop_id else p.next_stop_id end) = ns.stop_id
    where rot.feed_id = p.feed_id and rot.route_id = p.route_id;

    -- insert into rots.results (station_id) select station_id from rots.edges group by station_id; 
    with a as (select station_id, next_station_id from rots.edges group by station_id, next_station_id)
    insert into rots.results (station_id, next_stations, id) select station_id, array_agg(next_station_id) from a group by station_id;

    
      -- cnt := cnt + 1;
    -- drop function if exists ntf(); 
    -- create function 

    loop
      select * into edg from rots.results limit 1;
      delete from rots.results where results.id = edg.id;
    -- for edg in () loop

      for e in (select edg.id, unnest(edg.next_stations)) loop
        if () then
          insert into rots.rs select edg.station_id, edg.next_stations[0];
        end if;
      end loop;

      
      
    end loop;
    

    -- for edg in (select * from rots.results) loop

    -- end loop;
    -- for edg in (select * from rots.edges) loop
    --   raise notice '%', edg.station_id;
      -- update rots.results set next_stations = array_append(results.next_stations, (select edg.next_station_id)) where results.station_id = edg.station_id and next_stations ;
    -- end loop;

    -- insert into rots.indeg (station_id, deg)
    -- select n.station_id, coalesce(d.deg, 0)
    -- from (
    --   select distinct station_id from rots.edges
    --   union
    --   select distinct next_station_id as station_id from rots.edges 
    -- ) as n
    -- left join (
    --   select
    --     next_station_id as station_id,
    --     count(*) as deg
    --   from rots.edges
    --   group by next_station_id
    -- ) as d using(station_id);

    -- loop
    --   select station_id into curr_station_id
    --   from rots.indeg
    --   where deg = 0
    --   order by station_id
    --   limit 1;

    --   exit when not found;

    --   insert into rots.results (station_id) values (curr_station_id);

    --   update rots.indeg set deg = indeg.deg - sub.c
    --   from (
    --     select
    --       next_station_id as t,
    --       count(*) as c
    --     from rots.edges
    --     group by next_station_id
    --   ) as sub
    --   where indeg.station_id = sub.t;

    --   delete from rots.edges where station_id = curr_station_id;
    --   delete from rots.indeg where station_id = curr_station_id;

    -- end loop;
  end loop;
end;
$$ language plpgsql;
-- select * from stop_patterns;
-- select results.*, station_name from rots.results inner join parent_stations using (station_id);

select * from rots.results;
drop schema rots cascade;
