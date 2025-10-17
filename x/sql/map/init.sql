create schema if not exists busmap;

drop table if exists busmap.maproutes;
create table busmap.maproute(
  maproute_id integer primary key,
  maproute_name text,
  geom geometry(multilinestring, 4326)
);

drop table if exists busmap.mappatterns;
create table busmap.mappattern(
  pattern_id integer primary key,
  maproute_id integer,
  stop_sequence integer,
  geom_sequence integer,
  feed_id text,
  route_id text,
  route_name text,
  geom geometry(linestring, 4326)
);

drop table if exists busmap.mapstations;
create table busmap.stations(
  mapstation_id integer primary key,
  mapstation_name text,
  geom geometry(polygon, 4326)
);

drop table if exists busmap.mapstops;
create table busmap.mapstops(
  pattern_id integer,
  stop_sequence integer,
  mappattern_sequence integer,
  maproute_id integer,
  feed_id text,
  route_id text,
  route_name text,
  stop_name text,
  geom geometry(point, 4326)
);

-- drop table if exists busmap.mapstoppatterns;
-- create table busmap.mapstoppatterns(
--   maproute_id integer,
--   mappattern_sequence integer,
--   mapstation_id integer,
--   stop_name text,
--   geom geometry(point, 4326)
-- );