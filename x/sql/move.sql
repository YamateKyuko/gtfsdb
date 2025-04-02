insert into feed (
  feed_id,
  feed_url,
  feed_import,
  feed_publisher_name,
  feed_publisher_url,
  feed_lang,
  feed_version
)
select
  feed_id,
  feed_publisher_url,
  crnt,
  feed_publisher_name,
  feed_publisher_url,
  feed_lang,
  feed_version
from r.feed_info, (select CURRENT_DATE::varchar(10) as crnt)
on conflict do nothing;

insert into agency (
  feed_id,
  agency_id,
  agency_name,
  agency_url,
  agency_timezone,
  agency_lang,
  agency_phone,
  agency_fare_url,
  agency_email,
	
  agency_official_name,
  agency_zip_number,
  agency_address,
  agency_president_pos,
  agency_president_name
)
select
  feed_id,
  agency_id,
  agency_name,
  agency_url,
  agency_timezone,
  agency_lang,
  agency_phone,
  agency_fare_url,
  agency_email,

  agency_official_name,
  agency_zip_number,
  agency_address,
  agency_president_pos,
  agency_president_name
from r.agency
left join r.agency_jp using (feed_id, agency_id)
on conflict do nothing;

insert into routes (
  feed_id,
  route_id,
  agency_id,
  route_name,
  route_short_name,
  route_long_name,
  route_desc,
  route_type,
  route_url,
  route_color,
  route_text_color,
  route_sort_order,
  jp_parent_route_id
)
select
  feed_id,
  route_id,
  agency_id,
  coalesce(route_short_name, route_long_name) as route_name,
  route_short_name,
  route_long_name,
  route_desc,
  route_type,
  route_url,
  route_color,
  route_text_color,
  route_sort_order,
  jp_parent_route_id
from r.routes
on conflict do nothing;

insert into services (
  feed_id,
  service_id
)
select
  feed_id,
  service_id
from r.calendar
union
select
  feed_id,
  service_id
from r.calendar_dates
order by service_id
on conflict do nothing;

insert into calendar (
  feed_id,
  service_id,
  date
)
with series as (
  SELECT 
    feed_id,
    sunday,
    monday,
    tuesday,
    wednesday,
    thursday,
    friday,
    saturday,
    service_id,
    generate_series(
      r.calendar.start_date::date,
      r.calendar.end_date::date,
      '1 day'
    )::date as date
  FROM r.calendar
),
dowck as (
  select
    feed_id,
    service_id,
    to_char(date, 'YYYYMMDD') as date
  from series
  where
    (series.sunday = 1 and extract(dow from date) = 0) or 
    (series.monday = 1 and extract(dow from date) = 1) or 
    (series.tuesday = 1 and extract(dow from date) = 2) or 
    (series.wednesday = 1 and extract(dow from date) = 3) or 
    (series.thursday = 1 and extract(dow from date) = 4) or 
    (series.friday = 1 and extract(dow from date) = 5) or 
    (series.saturday = 1 and extract(dow from date) = 6)
)
select
  distinct on (
    feed_id,
    service_id,
    date
  )
  feed_id,
  service_id,
  to_char(to_date(date, 'YYYYMMDD'), 'YYYY-MM-DD') as date
from dowck
right join r.calendar_dates using(feed_id,service_id,date)
where
  exception_type != 2 or
  exception_type = 1 or
  exception_type is null;

insert into trips (
  feed_id,
  trip_id,
  route_id,
  service_id,
  trip_headsign,
  trip_short_name,
  direction_id,
  block_id,
  shape_id,
  wheelchair_accessible,
  bikes_allowed,
  jp_trip_desc,
  jp_trip_desc_symbol,
  jp_office_id,
  jp_trip_desc_detail,
  pattern_id
)
select 
  feed_id,
  trip_id,
  route_id,
  service_id,
  trip_headsign,
  trip_short_name,
  direction_id,
  block_id,
  shape_id,
  wheelchair_accessible,
  bikes_allowed,
  jp_trip_desc,
  jp_trip_desc_symbol,
  jp_office_id,
  null,
  null
from r.trips
on conflict do nothing;

insert into stops (
  feed_id,
  stop_id,
  stop_code,
  stop_name,
  stop_desc,
  stop_lat,
  stop_lon,
  zone_id,
  stop_url,
  location_type,
  station_id,
  parent_station,
  stop_timezone,
  wheelchair_boarding,
  platform_code
)
select
  feed_id,
  stop_id,
  stop_code,
  stop_name,
  stop_desc,
  stop_lat,
  stop_lon,
  zone_id,
  stop_url,
  location_type,
  null,
  parent_station,
  stop_timezone,
  wheelchair_boarding,
  platform_code
from r.stops
on conflict do nothing;

insert into stop_times (
  feed_id,
  trip_id,
  arrival_time,
  departure_time,
  stop_id,
  stop_sequence,
  stop_headsign,
  pickup_type,
  drop_off_type,
  shape_dist_traveled
)
select
  feed_id,
  trip_id,
  r.to_second(arrival_time),
  r.to_second(departure_time),
  stop_id,
  stop_sequence,
  stop_headsign,
  pickup_type,
  drop_off_type,
  shape_dist_traveled
from r.stop_times
on conflict do nothing;