create schema if not exists r;

-- feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version,feed_contact_email,feed_contact_url
-- feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version
drop table if exists r.feed_info cascade;
create table r.feed_info (
  feed_id integer,
  feed_publisher_name varchar(255),
  feed_publisher_url varchar(255),
  feed_lang varchar(15),
  feed_start_date varchar(8),
  feed_end_date varchar(8),
  feed_version varchar(63),
  feed_contact_email varchar(255),
  feed_contact_url varchar(255)
);

-- agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email
-- agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email
drop table if exists r.agency cascade;
create table r.agency (
  feed_id integer,
  agency_id varchar(63),
  agency_name varchar(63),
  agency_url varchar(63),
  agency_timezone varchar(15),
  agency_lang varchar(15),
  agency_phone varchar(31),
  agency_fare_url varchar(255),
  agency_email varchar(255)
);

-- 
-- agency_id,agency_official_name,agency_zip_number,agency_address,agency_president_pos,agency_president_name
drop table if exists r.agency_jp cascade;
create table r.agency_jp (
  feed_id integer,
  agency_id varchar(63),
  agency_official_name varchar(63),
  agency_zip_number varchar(63),
  agency_address varchar(15),
  agency_president_pos varchar(15),
  agency_president_name varchar(31)
);

-- route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color,route_sort_order,jp_parent_route_id
-- route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color,                 jp_parent_route_id
drop table if exists r.routes cascade;
create table r.routes (
  feed_id integer,
  route_id varchar(63),
  agency_id varchar(63),
  route_name varchar(255),
  route_short_name varchar(63),
  route_long_name varchar(255),
  route_desc varchar(255),
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)),
  route_url varchar(255),
  route_color varchar(6),
  route_text_color varchar(6),
  route_sort_order integer,
  jp_parent_route_id varchar(63)
);

-- service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
-- service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
drop table if exists r.calendar cascade;
create table r.calendar (
  feed_id integer,
  service_id varchar(63),
  monday integer check (monday in (0, 1)),
  tuesday integer check (tuesday in (0, 1)),
  wednesday integer check (wednesday in (0, 1)),
  thursday integer check (thursday in (0, 1)),
  friday integer check (friday in (0, 1)),
  saturday integer check (saturday in (0, 1)),
  sunday integer check (sunday in (0, 1)),
  start_date varchar(10),
  end_date varchar(10)
);

-- service_id,date,exception_type
-- service_id,date,exception_type
drop table if exists r.calendar_dates cascade;
create table r.calendar_dates (
  feed_id integer,
  service_id varchar(63),
  date varchar(8),
  exception_type integer
);

-- route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id,wheelchair_accessible,bikes_allowed,jp_trip_desc,jp_trip_desc_symbol,jp_office_id,jp_pattern_id
-- route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id,wheelchair_accessible,bikes_allowed,jp_trip_desc,jp_trip_desc_symbol,jp_office_id
drop table if exists r.trips cascade;
create table r.trips (
  feed_id integer,
  route_id varchar(63),
  service_id varchar(63),
  trip_id varchar(63),
  trip_headsign varchar(255),
  trip_short_name varchar(63),
  direction_id integer check (direction_id in (0, 1)),
  block_id varchar(63),
  shape_id varchar(63),
  wheelchair_accessible integer check (wheelchair_accessible in (0, 1, 2)),
  bikes_allowed integer check (bikes_allowed in (0, 1, 2)),
  jp_trip_desc varchar(255),
  jp_trip_desc_symbol varchar(255),
  jp_office_id varchar(63),
  jp_pattern_id varchar(63)
);

-- stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding,level_id,platform_code
-- stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding,         platform_code
drop table if exists r.stops cascade;
create table r.stops (
  feed_id integer,
  stop_id varchar(63),
  stop_code varchar(255),
  stop_name varchar(63),
  stop_desc varchar(255),
  stop_lat double precision,
  stop_lon double precision,
  zone_id varchar(63),
  stop_url varchar(255),
  location_type integer check (location_type in (0, 1)),
  parent_station varchar(63),
  stop_timezone varchar(15),
  wheelchair_boarding integer check (wheelchair_boarding in (0, 1, 2)),
  level_id varchar(255),
  platform_code varchar(255)
);

-- trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint
-- trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint
drop table if exists r.stop_times cascade;
create table r.stop_times (
  feed_id integer,
  trip_id varchar(63),
  arrival_time varchar(15),
  departure_time varchar(15),
  stop_id varchar(63),
  stop_sequence integer,
  stop_headsign varchar(63),
  pickup_type integer check (pickup_type in (0, 1, 2, 3)),
  drop_off_type integer check (drop_off_type in (0, 1, 2, 3)),
  shape_dist_traveled varchar(255),
  timepoint integer
);

-- feed_id設定 必ず実行
drop function if exists r.feed_ider(integer) cascade;
create function r.feed_ider(integer) returns void as $$
  update r.feed_info set feed_id = $1;
  update r.agency set feed_id = $1;
  update r.agency_jp set feed_id = $1;
  update r.routes set feed_id = $1;
  update r.calendar set feed_id = $1;
  update r.calendar_dates set feed_id = $1;
  update r.trips set feed_id = $1;
  update r.stops set feed_id = $1;
  update r.stop_times set feed_id = $1;
$$ language sql;

drop function if exists r.to_second(varchar(8));
create function r.to_second(
  varchar(8)
) returns integer as $$
  SELECT (
    split_part($1, ':', 1)::smallint * 3600 +
    split_part($1, ':', 2)::smallint * 60 +
    split_part($1, ':', 3)::smallint 
  )::integer
$$ language sql;


-- "feed_info"
-- "agency"
-- "routes"
-- "calendar"
-- "calendar_dates"
-- "trips"
-- "stops"
-- "stop_times"