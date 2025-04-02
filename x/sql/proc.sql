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

-- trip_patterns_insert
with trip_stop_list as (
	select
		tim.feed_id,
		rot.agency_id,
		rot.route_type,
		trp.route_id,
		trp.direction_id,
		tim.trip_id,
		array_agg(tim.stop_id order by tim.stop_sequence) as stop_list,
		array_agg(tim.stop_headsign order by tim.stop_sequence) as headsign_list
	from stop_times as tim
	inner join trips as trp using (feed_id, trip_id)
	inner join routes as rot using (feed_id, route_id)
	group by
		tim.feed_id,
		rot.agency_id,
		rot.route_type,
		trp.route_id,
		trp.direction_id,
		tim.trip_id
),
id_named as (
	select
		dense_rank() over(
			order by
				feed_id,
				agency_id,
				route_type,
				route_id,
				direction_id,
				stop_list,
				headsign_list
		) as pattern_id,
		*
	from trip_stop_list
),
update_trips as (
	update trips as trp
	set pattern_id = lis.pattern_id
	from id_named as lis
	where
		trp.feed_id =  lis.feed_id and
		trp.trip_id = lis.trip_id
),
grouped as (
	select
		feed_id,
		pattern_id,
		agency_id,
		route_type,
		route_id,
		direction_id,
		stop_list,
		headsign_list
	from id_named
	group by
		feed_id,
		pattern_id,
		agency_id,
		route_type,
		route_id,
		direction_id,
		stop_list,
		headsign_list
),
joined as (
	select
		lis.feed_id,
		lis.pattern_id,
		lis.agency_id,
		lis.route_type,
		lis.route_id,
		lis.direction_id,
		rot.route_name
	from grouped as lis
	inner join routes as rot
		using (feed_id, route_id)
)
insert into trip_patterns (
	feed_id,
	pattern_id,
	agency_id,
	route_type,
	route_id,
	direction_id,
	route_name
)
select
	*
from joined
order by pattern_id asc
;

-- stop_patterns_insert
insert into stop_patterns (
	feed_id,
	pattern_id,
	agency_id,
	route_type,
	route_id,
	stop_headsign,
	direction_id,
	route_name,
	stop_id,
	next_stop_id,
	stop_sequence,
	stop_name,
	platform_code,
	zone_id,
	duration_time
)
with leaded as (
	select 
		tim.feed_id,
		tim.trip_id,
		row_number() over(
			partition by
				feed_id,
				trip_id
			order by
				tim.stop_sequence
		) as stop_sequence,
		tim.stop_headsign,
		tim.stop_id,
		lead(tim.stop_id, 1, null)
			over(partition by tim.feed_id, tim.trip_id order by tim.stop_sequence) as next_stop_id,
		tim.departure_time,
		lead(tim.arrival_time, 1, null)
			over(partition by tim.feed_id, tim.trip_id order by tim.stop_sequence) as next_arrival_time
	from stop_times as tim
)
select
	tim.feed_id,
	tpt.pattern_id,
	tpt.agency_id,
	tpt.route_type,
	tpt.route_id,
	tim.stop_headsign,
	tpt.direction_id,
	tpt.route_name,
	tim.stop_id,
	tim.next_stop_id,
	tim.stop_sequence,
	stp.stop_name,
	stp.platform_code,
	stp.zone_id,
	percentile_cont(0.5) within group (
		order by (
			tim.next_arrival_time -
			tim.departure_time
		)) as duration_time
from leaded as tim
inner join trips as trp
	using (feed_id, trip_id)
inner join trip_patterns as tpt
	using (feed_id, pattern_id)
inner join stops as stp
	using (feed_id, stop_id)
group by
	tim.feed_id,
	tpt.pattern_id,
	tpt.agency_id,
	tpt.route_type,
	tpt.route_id,
	tpt.direction_id,
	tim.stop_headsign,
	tpt.route_name,
	tim.stop_id,
	tim.next_stop_id,
	tim.stop_sequence,
	stp.stop_name,
	stp.platform_code,
	stp.zone_id
order by
	pattern_id,
	stop_sequence
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