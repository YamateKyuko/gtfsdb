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
