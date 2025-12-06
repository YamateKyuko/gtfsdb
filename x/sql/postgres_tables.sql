
drop table if exists feed cascade;
create table feed (
  feed_id integer not null,
  feed_url varchar(255) not null,
  feed_import varchar(10) not null,
  feed_publisher_name varchar(255) not null,
  feed_publisher_url varchar(255) not null,
  feed_lang varchar(15) not null,
  feed_version varchar(63),
  primary key (feed_id)
);
-- create index if not exists ix_feed_feed_id on feed(feed_id);

drop table if exists agency cascade;
create table agency (
  feed_id smallint not null,
  agency_id varchar(63),
  agency_name varchar(63) not null,
  agency_url varchar(63) not null,
  agency_timezone varchar(15) not null,
  agency_lang varchar(15) not null,
  agency_phone varchar(31),
  agency_fare_url varchar(255),
  agency_email varchar(255),
  agency_official_name varchar(255),
  agency_zip_number varchar(15),
  agency_address varchar(255),
  agency_president_pos varchar(63),
  agency_president_name varchar(63),
  primary key (agency_id),
  constraint fk_agency_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
-- create index if not exists ix_agency_agency_id on agency(feed_id, agency_id);

drop table if exists routes cascade;
create table routes (
  feed_id smallint not null,
  route_id varchar(63) not null,
  agency_id varchar(63) not null,
  route_name varchar(255),
  route_short_name varchar(63),
  route_long_name varchar(255),
  route_desc varchar(255),
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)),
  route_url varchar(255),
  route_color varchar(6),
  route_text_color varchar(6),
  route_sort_order integer,
  jp_parent_route_id varchar(63),
  primary key (feed_id, route_id),
  constraint fk_routes_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade,
  constraint fk_routes_agency_id foreign key (agency_id) references agency(agency_id) on delete cascade on update cascade,
  constraint ch_routes_short_long_name check ((route_short_name=null and route_long_name!=null) or (route_short_name!=null and route_long_name=null) or (route_short_name!=null and route_long_name!=null))
);
-- create index if not exists ix_routes_route_id on routes(feed_id, route_id);

drop table if exists services cascade;
create table services (
  feed_id smallint not null,
  service_id varchar(63),
  primary key (feed_id, service_id),
  constraint fk_services_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
-- create index if not exists ix_services_service_id on services(feed_id, service_id);

drop table if exists calendar cascade;
create table calendar (
  feed_id smallint not null,
  service_id varchar(63) not null,
  date varchar(10) not null,
  primary key (feed_id, service_id, date),
  constraint fk_calendar_service_id foreign key (feed_id, service_id) references services(feed_id, service_id) on delete cascade on update cascade
);
-- create index if not exists ix_calendar_service_id on calendar(feed_id, service_id);

drop table if exists trip_patterns cascade;
create table trip_patterns (
  feed_id smallint not null,
  pattern_id integer not null,
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)) not null,
  route_id varchar(63),
  agency_id varchar(63),
  direction_id integer check (direction_id in (0, 1)),
  route_name varchar(255) not null,

  first_stop_id varchar(63),
  last_stop_id varchar(63),
  first_stop_name varchar(255),
  
  primary key (pattern_id)
);
-- create index if not exists ix_trip_patterns_pattern_id on trip_patterns(pattern_id);

drop table if exists trips cascade;
create table trips (
  feed_id smallint not null,
  trip_id varchar(63),
  route_id varchar(63) not null,
  service_id varchar(63) not null,
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
  jp_trip_desc_detail varchar(255),
  pattern_id integer,

  -- offset_id integer,
  -- diff_time integer,

  primary key (feed_id, trip_id),
  constraint fk_trips_route_id foreign key (feed_id, route_id) references routes(feed_id, route_id) on delete cascade on update cascade,
  constraint fk_trips_service_id foreign key (feed_id, service_id) references services(feed_id, service_id) on delete cascade on update cascade
);
-- create index if not exists ix_trips_trip_id on trips(feed_id, trip_id);

drop table if exists parent_stations cascade;
create table parent_stations (
  station_id integer not null,
  station_name varchar(255) not null,
  station_muni integer,
  station_town varchar(255),
  station_lat double precision,
  station_lon double precision,
  primary key (station_id)
);
-- create index if not exists ix_parent_stations_station_id on parent_stations(station_id);

drop table if exists stops cascade;
create table stops (
  feed_id smallint not null,
  stop_id varchar(63) not null,
  stop_code varchar(255),
  stop_name varchar(63) not null,
  stop_desc varchar(255),
  stop_lat double precision,
  stop_lon double precision,
  zone_id varchar(63),
  stop_url varchar(255),
  location_type integer,
  station_id integer,
  parent_station varchar(255),
  stop_timezone varchar(15),
  wheelchair_boarding integer check (wheelchair_boarding in (0, 1, 2)),
  platform_code varchar(255),
  primary key (feed_id, stop_id),
  constraint fk_stops_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
-- create index if not exists ix_stops_stop_id on stops(feed_id, stop_id);

drop table if exists stop_times cascade;
create table stop_times (
  feed_id smallint not null,
  trip_id varchar(63),
  arrival_time integer not null,
  departure_time integer not null,
  stop_id varchar(63) not null,
  stop_sequence integer not null,
  stop_headsign varchar(63),
  pickup_type integer check (pickup_type in (0, 1, 2, 3)),
  drop_off_type integer check (drop_off_type in (0, 1, 2, 3)),
  shape_dist_traveled varchar(255),
  pattern_id integer,
  primary key (feed_id, trip_id, stop_sequence),
  constraint fk_stop_times_trip_id foreign key (feed_id, trip_id) references trips(feed_id, trip_id) on delete cascade on update cascade,
  constraint fk_stop_times_stop_id foreign key (feed_id, stop_id) references stops(feed_id, stop_id) on delete cascade on update cascade
);
-- create index if not exists ix_stop_times_trip_id on stop_times(feed_id, trip_id);

drop table if exists stop_patterns cascade;
create table stop_patterns (
  feed_id smallint not null,
  pattern_id integer not null,
  agency_id varchar(63) not null,
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)),
  route_id varchar(63) not null,
  route_name varchar(255) not null,
  direction_id integer check (direction_id in (0, 1)),
  stop_sequence integer not null,
  stop_id varchar(63) not null,
  stop_name varchar(63) not null,
  stop_headsign varchar(63),
  platform_code varchar(255),
  next_stop_id varchar(63),
  zone_id varchar(63),
  duration_time integer,
  offset_time integer,

  -- parent_id varchar(255),

  primary key (pattern_id, stop_sequence)
);
-- create index if not exists ix_stop_patterns_stop_sequence on stop_patterns(pattern_id, stop_sequence);

-- drop table if exists stop_offsets cascade;
-- create table stop_offsets (
--   feed_id smallint not null,
-- 	offset_id integer not null,
--   pattern_id integer not null,
-- 	stop_id varchar(63) not null,
-- 	stop_sequence integer,
--   arrival_offset integer not null,
--   departure_offset integer not null,
--   stop_headsign varchar(63),
--   pickup_type integer check (pickup_type in (0, 1, 2, 3)),
--   drop_off_type integer check (drop_off_type in (0, 1, 2, 3)),
--   shape_dist_traveled varchar(255),
--   primary key (feed_id, offset_id, stop_sequence)
-- );
-- create index if not exists ix_stop_times_trip_id on stop_times(feed_id, trip_id);





drop table if exists fare_attributes cascade;
create table fare_attributes (
  feed_id smallint not null,
  fare_id varchar(63) not null,
  price float not null,
  ic_price float,
  currency_type varchar(15) not null, -- 通貨
  payment_method integer not null check (payment_method in (0, 1)), -- 後払い, 先払い
  transfers integer,
  transfer_duration integer, -- 乗り換え可能時間
  primary key (feed_id, fare_id)
);
-- create index if not exists ix_fare_attributes_fare_id on fare_attributes(feed_id, fare_id);

drop table if exists fare_rules cascade;
create table fare_rules (
  feed_id smallint not null,
  fare_id varchar(63) not null,
  route_id varchar(63) not null,
  origin_id varchar(63),
  destination_id varchar(63),
  constraint fk_fare_rules_fare_id foreign key (feed_id, fare_id) references fare_attributes(feed_id, fare_id) on delete cascade on update cascade,
  constraint fk_fare_rules_route_id foreign key (feed_id, route_id) references routes(feed_id, route_id) on delete cascade on update cascade,
  unique(feed_id, fare_id, route_id, origin_id, destination_id)
);
-- create index if not exists ix_fare_rules_zone_id on fare_rules(feed_id, fare_id, origine_id, destination_id);

-- drop table if exists translations cascade;
-- create table translations (
--   -- feed_id integer,
--   -- table_name varchar(63) not null,
--   -- field_name varchar(63) not null,
--   -- language varchar(15) not null, -- 言語
--   -- translation varchar(255) not null, -- 翻訳先
--   -- record_id varchar(63) not null,
--   -- record_sub_id varchar(63) not null,
--   -- field_value varchar(255) not null -- 翻訳元


--   feed_id smallint not null,
--   table_name varchar(63) not null check (table_name in ('agency', 'stops', 'routes', 'trips', 'stop_times', 'feed_info')),
--   field_name varchar(63) not null,
--   language varchar(15) not null check (language in ('ja', 'ja-Hrkt', 'en')), -- 言語
--   translation varchar(255) not null, -- 翻訳先
--   record_id varchar(63),
--   record_sub_id varchar(63),
--   field_value varchar(255) -- 翻訳元


--   -- translation_type varchar(63) not null check (translation_type in ('stop_name')),
--   -- record_id varchar(63) not null,
--   -- primary key (feed_id, language, translation_type, record_id)
-- );

-- drop table if exists stop_translations cascade;
-- create table stop_translations (
--   feed_id smallint not null,
--   stop_id varchar(63) not null,
--   language varchar(15) not null check (language in ('ja', 'ja-Hrkt', 'en')), -- 言語
--   translation varchar(255) not null, -- 翻訳先
--   primary key (feed_id, language, stop_id)
-- );

drop table if exists stop_name_translations cascade;
create table stop_name_translations (
  feed_id smallint not null,
  stop_id varchar(63),
  language varchar(7) not null,
  translation varchar(255),
  stop_name varchar(255),
  unique (feed_id, stop_id, language, stop_name)
);

drop table if exists stop_headsign_translations cascade;
create table stop_headsign_translations (
  feed_id integer not null,
  trip_id varchar(63),
  stop_sequence integer,
  language varchar(7) not null,
  translation varchar(255),
  stop_headsign varchar(255),
  unique (feed_id, trip_id, stop_sequence, language, stop_headsign)
);

drop table if exists route_short_name_translations cascade;
create table route_short_name_translations (
  feed_id integer not null,
  route_id varchar(63),
  language varchar(7) not null,
  translation varchar(255),
  route_short_name varchar(255),
  unique (feed_id, route_id, language, route_short_name)
);

drop table if exists trip_headsign_translations cascade;
create table trip_headsign_translations (
  feed_id integer not null,
  trip_id varchar(63),
  language varchar(7) not null,
  translation varchar(255),
  trip_headsign varchar(255),
  unique (feed_id, trip_id, language, trip_headsign)
);










drop table if exists holidays;
create table holidays (
	holiday_date varchar(15),
	holiday_name varchar(31),
	holiday_day varchar(3)
);

drop table if exists daytype_cnt;
create table daytype_cnt (
	feed_id integer not null,
	route_id varchar(255) not null,
	pattern_id integer not null,
	daytype varchar(2),
	cnt integer not null
);


drop function if exists ud_to_second(varchar(8));
create function
ud_to_second(
varchar(8)
) returns integer as $$
SELECT (
split_part($1, ':', 1)::smallint * 3600 +
split_part($1, ':', 2)::smallint * 60 +
split_part($1, ':', 3)::smallint 
)::integer
$$ language sql;

drop function if exists ud_to_day(date);
create function ud_to_day(date)
returns varchar(3) as $$
SELECT
(array['日','月','火','水','木','金','土'])[EXTRACT(DOW FROM CAST($1 AS DATE)) + 1]
$$ language sql;

drop function if exists ud_is_holiday(date);
create function ud_is_holiday(date) returns bool as $$
select 
holiday_name is not null
from holidays
where holiday_date = to_char($1, 'YYYY-MM-DD')
limit 1;
$$ language sql;

drop function if exists ud_to_daytype(date);
create function ud_to_daytype(date) returns varchar(2) as $$
select
case ud_is_holiday($1)
when true then '祝'
else case ud_to_day($1) 
  when '日' then '日'
  when '土' then '土'
  else '平'
end
end;
$$ language sql;

