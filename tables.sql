drop table if exists stop_patterns;
drop table if exists trip_patterns;
drop table if exists parent_stations;
drop table if exists stop_times;
drop table if exists stops;
drop table if exists trips;
drop table if exists calendar;
drop table if exists services;
drop table if exists routes;
drop table if exists agency;
drop table if exists feed;


create table feed (
  feed_id integer not null,
  feed_url text not null,
  feed_import text not null,
  feed_publisher_name text not null,
  feed_publisher_url text not null,
  feed_lang text not null,
  feed_version text,
  primary key (feed_id)
);
create index if not exists ix_feed_feed_id on feed(feed_id);


create table agency (
  feed_id smallint not null,
  agency_id text,
  agency_name text not null,
  agency_url text not null,
  agency_timezone text not null,
  agency_lang text not null,
  agency_phone text,
  agency_fare_url text,
  agency_email text,
  agency_official_name text,
  agency_zip_number text,
  agency_address text,
  agency_president_pos text,
  agency_president_name text,
  primary key (agency_id),
  constraint fk_agency_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
create index if not exists ix_agency_agency_id on agency(feed_id, agency_id);


create table routes (
  feed_id smallint not null,
  route_id text not null,
  agency_id text not null,
  route_name text,
  route_short_name text,
  route_long_name text,
  route_desc text,
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109)),
  route_url text,
  route_color text,
  route_text_color text,
  route_sort_order integer,
  jp_parent_route_id text,
  primary key (feed_id, route_id),
  constraint fk_routes_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade,
  constraint fk_routes_agency_id foreign key (agency_id) references agency(agency_id) on delete cascade on update cascade,
  constraint ch_routes_short_long_name check ((route_short_name=null and route_long_name!=null) or (route_short_name!=null and route_long_name=null) or (route_short_name!=null and route_long_name!=null))
);
create index if not exists ix_routes_route_id on routes(feed_id, route_id);


create table services (
  feed_id smallint not null,
  service_id text,
  primary key (feed_id, service_id),
  constraint fk_services_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
create index if not exists ix_services_service_id on services(feed_id, service_id);


create table calendar (
  feed_id smallint not null,
  service_id text not null,
  date text not null,
  primary key (feed_id, service_id, date),
  constraint fk_calendar_service_id foreign key (feed_id, service_id) references services(feed_id, service_id) on delete cascade on update cascade
);
create index if not exists ix_calendar_service_id on calendar(feed_id, service_id);


create table trip_patterns (
  feed_id smallint not null,
  pattern_id integer not null,
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)) not null,
  route_id text,
  agency_id text,
  direction_id integer check (direction_id in (0, 1)),
  route_name text not null,
  primary key (pattern_id)
);
create index if not exists ix_trip_patterns_pattern_id on trip_patterns(pattern_id);


create table trips (
  feed_id smallint not null,
  trip_id text,
  route_id text not null,
  service_id text not null,
  trip_headsign text,
  trip_short_name text,
  direction_id integer check (direction_id in (0, 1)),
  block_id text,
  shape_id text,
  wheelchair_accessible integer check (wheelchair_accessible in (0, 1, 2)),
  bikes_allowed integer check (bikes_allowed in (0, 1, 2)),
  jp_trip_desc text,
  jp_trip_desc_symbol text,
  jp_office_id text,
  jp_trip_desc_detail text,
  pattern_id integer,
  primary key (feed_id, trip_id),
  constraint fk_trips_route_id foreign key (feed_id, route_id) references routes(feed_id, route_id) on delete cascade on update cascade,
  constraint fk_trips_service_id foreign key (feed_id, service_id) references services(feed_id, service_id) on delete cascade on update cascade
);
create index if not exists ix_trips_trip_id on trips(feed_id, trip_id);


create table parent_stations (
  station_id integer not null,
  station_name text not null,
  station_muni integer,
  station_town text,
  station_lat double precision,
  station_lon double precision,
  primary key (station_id)
);
create index if not exists ix_stations_station_id on parent_stations(station_id);


create table stops (
  feed_id smallint not null,
  stop_id text not null,
  stop_code text,
  stop_name text not null,
  stop_desc text,
  stop_lat double precision,
  stop_lon double precision,
  zone_id text,
  stop_url text,
  location_type integer check (location_type in (0, 1)),
  station_id integer,
  parent_station text,
  stop_timezone text,
  wheelchair_boarding integer check (wheelchair_boarding in (0, 1, 2)),
  platform_code text,
  primary key (feed_id, stop_id),
  constraint fk_stops_feed_id foreign key (feed_id) references feed(feed_id) on delete cascade on update cascade
);
create index if not exists ix_stops_stop_id on stops(feed_id, stop_id);


create table stop_times (
  feed_id smallint not null,
  trip_id text,
  arrival_time integer not null,
  departure_time integer not null,
  stop_id text not null,
  stop_sequence integer,
  stop_headsign text,
  pickup_type integer check (pickup_type in (0, 1, 2, 3)),
  drop_off_type integer check (drop_off_type in (0, 1, 2, 3)),
  shape_dist_traveled text,
  primary key (feed_id, trip_id, stop_sequence),
  constraint fk_stop_times_trip_id foreign key (feed_id, trip_id) references trips(feed_id, trip_id) on delete cascade on update cascade,
  constraint fk_stop_times_stop_id foreign key (feed_id, stop_id) references stops(feed_id, stop_id) on delete cascade on update cascade
);
create index if not exists ix_stop_times_trip_id on stop_times(feed_id, trip_id);


create table stop_patterns (
  feed_id smallint not null,
  pattern_id integer not null,
  agency_id text not null,
  route_type integer check (route_type in (0, 1, 2, 3, 4, 5, 6, 7)),
  route_id text not null,
  stop_headsign text,
  direction_id integer check (direction_id in (0, 1)),
  route_name text not null,
  stop_id text not null,
  next_stop_id text,
  stop_sequence integer not null,
  stop_name text not null,
  platform_code text,
  zone_id text,
  duration_time integer,
  primary key (pattern_id, stop_sequence)
);
create index if not exists ix_stop_patterns_stop_sequence on stop_patterns(pattern_id, stop_sequence);
