with fsvl as (
	select 
		tim.feed_id,
		trip_id,
		first_value(arrival_time) over(partition by tim.feed_id, tim.trip_id order by stop_sequence) as diff_time,
		arrival_time,
		departure_time,
		stop_id,
		stop_sequence,
		stop_headsign,
		pickup_type,
		drop_off_type,
		shape_dist_traveled
	from stop_times as tim
),
ofst as (
	select 
		tim.feed_id,
		pattern_id,
		trip_id,
		tim.diff_time,
		(arrival_time - tim.diff_time) as arrival_offset,
		(departure_time - tim.diff_time) as departure_offset,
		stop_id,
		stop_sequence,
		stop_headsign,
		pickup_type,
		drop_off_type,
		shape_dist_traveled
	from fsvl as tim
	inner join trips using(feed_id, trip_id)
	inner join trip_patterns using(pattern_id)
),
arrayed as (
	select 
		feed_id,
		trip_id,
		pattern_id,
		diff_time,
		array_agg(arrival_offset order by stop_sequence) as arrival_offset_list,
		array_agg(departure_offset order by stop_sequence) as departure_offset_list,
		array_agg(pickup_type order by stop_sequence) as pickup_list,
		array_agg(drop_off_type order by stop_sequence) as drop_off_list
	from ofst
	group by
		feed_id,
		trip_id,
		pattern_id,
		diff_time
),
grouped as (
	select 
		feed_id,
		trip_id,
		diff_time,
		dense_rank() over(
			order by
				feed_id,
				pattern_id,
				pattern_id,
				arrival_offset_list,
				departure_offset_list,
				pickup_list,
				drop_off_list
		) as offset_id
	from arrayed
)
update trips as trp
	set (offset_id, diff_time) = (dif.offset_id, dif.diff_time)
from grouped as dif
where
	trp.feed_id = dif.feed_id and
	trp.trip_id = dif.trip_id;


insert into stop_offsets (
  feed_id,
	offset_id,
  pattern_id,
	stop_sequence,
	stop_id,
  arrival_offset,
  departure_offset,
  stop_headsign,
  pickup_type,
  drop_off_type
)
select 
distinct on (offset_id, stop_sequence)
  feed_id,
	offset_id,
  pattern_id,
  stop_sequence,
	stop_id,
  arrival_time - first_value(arrival_time) over(partition by tim.feed_id, tim.trip_id order by stop_sequence) as arrival_offset,
  departure_time - first_value(arrival_time) over(partition by tim.feed_id, tim.trip_id order by stop_sequence) as departure_offset,
  stop_headsign,
  pickup_type,
  drop_off_type
from stop_times as tim
inner join trips using(feed_id, trip_id);

