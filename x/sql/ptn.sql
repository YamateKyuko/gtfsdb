-- trips.pattern_id update
with trip_stop_list as (
	select
		tim.feed_id,
		tim.trip_id,
		array_agg(tim.stop_id order by tim.stop_sequence) as stop_list,
		array_agg(tim.stop_headsign order by tim.stop_sequence) as headsign_list
		-- array_agg(tim.pickup_type order by tim.stop_sequence) as pickup_list,
		-- array_agg(tim.drop_off_type order by tim.stop_sequence) as drop_off_list
	from stop_times as tim
	group by
		tim.feed_id,
		tim.trip_id
),
id_named as (
	select
		tim.feed_id,
		rot.agency_id,
		tim.trip_id,
		rot.route_type,
		trp.route_id,
		trp.direction_id,
		dense_rank() over(
			order by
				feed_id,
				agency_id,
				route_type,
				route_id,
				direction_id,
				stop_list,
				headsign_list
				-- pickup_list,
				-- drop_off_list
		) as pattern_id
	from trip_stop_list as tim
	inner join trips as trp using (feed_id, trip_id)
	inner join routes as rot using (feed_id, route_id)
)
update trips as trp
set pattern_id = tim.pattern_id
from id_named as tim
where
	trp.feed_id = tim.feed_id and
	trp.trip_id = tim.trip_id;

-- trip_patterns insert
with grouped as (
	select
		feed_id,
		pattern_id,
		route_id,
		direction_id
	from trips
	group by 1,2,3,4
	order by pattern_id
),
joined as (
	select
		lis.feed_id,
		lis.pattern_id,
		rot.agency_id,
		rot.route_type,
		rot.route_id,
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
;


-- stop_patterns_insert
with distincted as (
	select 
		distinct on (pattern_id)
		feed_id,
		trip_id,
		pattern_id,
		direction_id,
		route_id
	from trips as trp
)
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
	zone_id
)
select
	trp.feed_id,
	trp.pattern_id,
	rot.agency_id,
	rot.route_type,
	trp.route_id,
	tim.stop_headsign,
	trp.direction_id,
	rot.route_name,
	tim.stop_id,
	lead(tim.stop_id, 1, null)
			over(partition by tim.feed_id, tim.trip_id order by tim.stop_sequence) as next_stop_id,
	tim.stop_sequence,
	stp.stop_name,
	stp.platform_code,
	stp.zone_id
from distincted as trp
inner join routes as rot using (feed_id, route_id)
inner join stop_times as tim using (feed_id, trip_id)
inner join stops as stp using (feed_id, stop_id)
;

-- 
update stop_times as tim
set pattern_id = trp.pattern_id
from trips as trp
where
	tim.feed_id = trp.feed_id and
	tim.trip_id = trp.trip_id;