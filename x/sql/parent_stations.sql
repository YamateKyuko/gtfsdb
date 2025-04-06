-- next_stop_list_insert
drop table if exists next_stop_list;
create table next_stop_list as 
with stop_pair as (
	select 
		feed_id,
		least(stop_id, next_stop_id) as stop_id,
		greatest(stop_id, next_stop_id) as next_stop_id
	from stop_patterns
	where next_stop_id is not null
	group by 1, 2, 3
),
stop_list as (
	select 
		feed_id,
		stop_id,
		array_agg(next_stop_id) as stop_list
	from stop_pair
	group by feed_id, stop_id
),
next_stop_list as (
	select 
		feed_id,
		next_stop_id as stop_id,
		array_agg(stop_id) as stop_list
	from stop_pair
	group by feed_id, next_stop_id
)
select 
	feed_id,
	stop_id,
	stop_list.stop_list || next_stop_list.stop_list as list
from stop_list
inner join next_stop_list using(feed_id, stop_id)
;

-- parent_stations_insert
create extension postgis;

drop table if exists temps;
create table temps (
	feed_id integer not null,
	stop_id varchar(255) not null,
	stop_name varchar(255) not null,
	stop_geom geometry(Point, 3857) not null,
	visited bool default false not null,
	station_id integer
);

insert into temps
	select feed_id, stop_id, stop_name, st_point(stop_lon, stop_lat) as stop_geom, false, null
		from stops
		order by stop_id;

drop table if exists to_process;
create table to_process (
	feed_id integer not null,
	stop_id varchar(255) not null,
	stop_name varchar(255) not null,
	stop_geom geometry(Point, 3857) not null,
	primary key(feed_id, stop_id)
);

do $$
declare
	P record;
	C integer;
	Pd record;
	NPd record;
begin
	C := 0;
	for P in (select * from temps) loop
		-- raise notice '%-%-%', C, P.feed_id, P.stop_id;
		continue 	
			when (select visited from temps where P.feed_id = temps.feed_id and P.stop_id = temps.stop_id limit 1);
		update temps
			set visited = true
			where P.feed_id = temps.feed_id and P.stop_id = temps.stop_id;
		C := C + 1;
		update temps
			set station_id = C
			where P.feed_id = temps.feed_id and P.stop_id = temps.stop_id;
		insert into to_process (feed_id, stop_id, stop_name, stop_geom)
			values (P.feed_id, P.stop_id, P.stop_name, P.stop_geom);

		while (select count(*) from to_process) > 0 loop
			for Pd in (select * from to_process) loop
				-- raise notice '--%-%', Pd.feed_id, Pd.stop_id; 
				delete
					from to_process
					where Pd.feed_id = to_process.feed_id and Pd.stop_id = to_process.stop_id;

				for NPd in (
					select feed_id, stop_id, stop_name, stop_geom
						from temps
						where ( -- 距離判定
							( -- 同名かつ近くもしくは
								temps.stop_name = Pd.stop_name and
								ST_DWithin(temps.stop_geom, Pd.stop_geom, 0.005)
							) or ( -- とても近く
								ST_DWithin(temps.stop_geom, Pd.stop_geom, 0.0005)
							)
						) and ( -- 連続停車停留所除外 Pdは使わない
							temps.feed_id != P.feed_id or -- feedが一致しない若しくは
							temps.stop_id not in ( -- stopがリストにない
								select unnest(list) from next_stop_list as unable
								where 
									unable.feed_id = P.feed_id and
									unable.stop_id = P.stop_id
							)
						)
				) loop
					if not (
						select visited
							from temps
							where NPd.feed_id = temps.feed_id and NPd.stop_id = temps.stop_id
					) then
						update temps
							set visited = true
							where NPd.feed_id = temps.feed_id and NPd.stop_id = temps.stop_id;
							
						insert 
							into to_process 
							values (NPd.feed_id, NPd.stop_id, NPd.stop_name, NPd.stop_geom)
							on conflict do nothing;
					end if;

					update temps
						set station_id = C
						where 
							station_id is null and
							NPd.feed_id = temps.feed_id and
							NPd.stop_id = temps.stop_id;
				end loop;
			end loop;
		end loop;
	end loop;
end;
$$;

update stops set station_id = temps.station_id
	from temps
	where stops.feed_id = temps.feed_id and stops.stop_id = temps.stop_id;

insert 
	into parent_stations(
		station_id,
		station_name,
		station_lat,
		station_lon
	)
	select
		distinct on (station_id)
		station_id,
		stop_name as station_name,
		st_y(st_centroid(st_collect(stop_geom) over(partition by station_id))),
		st_x(st_centroid(st_collect(stop_geom) over(partition by station_id)))
	from temps;

drop table if exists temps cascade;
drop table if exists to_process cascade;

drop extension postgis;

-- next_stop_list_drop
drop table if exists next_stop_list;