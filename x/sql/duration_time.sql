with leaded as (
	select
		feed_id,
		trip_id,
		stop_sequence,
		departure_time,
		lead(tim.arrival_time, 1, null)
			over(partition by tim.feed_id, tim.trip_id order by tim.stop_sequence) as next_arrival_time
	from stop_times as tim
),
moded as (
	select 
		feed_id,
		pattern_id,
		stop_sequence,
		mode() within group (
			order by (
				next_arrival_time -
				departure_time
			)) as duration_time
		from leaded
		inner join trips using(feed_id, trip_id)
		group by
			feed_id,
			pattern_id,
			stop_sequence
),
ofst as (
	select 
		*,
		sum(duration_time) over(
			partition by pattern_id
			order by stop_sequence
			range between
				unbounded preceding and
				current row
				exclude current row
		) as offset_time
	from moded
)
update stop_patterns as ptn 
set
	(duration_time, offset_time) =
	(tim.duration_time, coalesce(tim.offset_time, 0))
from ofst as tim
where
	tim.pattern_id = ptn.pattern_id and
	tim.stop_sequence = ptn.stop_sequence;