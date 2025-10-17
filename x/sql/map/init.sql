create schema if not exists busmap;

drop table if exists busmap.patterns;
create table busmap.pattern(
  pattern_id integer,
  stop_sequence integer,
  geom_sequence integer,
  feed_id text,
  route_id text,
  route_name text,
  geom geometry(linestring, 4326)
);

drop table if exists busmap.stops;
create table busmap.pattern(
  pattern_id integer,
  stop_sequence integer,
  feed_id text,
  route_id text,
  route_name text,
  stop_name text,
  geom geometry(linestring, 4326)
);