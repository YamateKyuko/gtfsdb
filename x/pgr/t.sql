
-- drop table if exists kari;
-- create table if not exists kari(
--   id integer,
--   source integer,
--   target integer,
--   geom geometry(LineString, 4326),
--   cost float,
--   reverse_cost float,
--   multiplier float default 1.0,
--   capacity float default 1.0,
--   reverse_capacity float default 1.0
-- );


-- insert into kari (id, geom, cost, reverse_cost, source, target) values 
--   (1, 'linestring(0 0, 4 4)', 4.0, 4.0, 1, 2),
--   (2, 'linestring(4 4, 6 6)', 2.0, 2.0, 2, 3)
-- ;


-- select *
-- from pgr_dijkstra('select id, source, target, cost * multiplier, reverse_cost, capacity, reverse_capacity from kari', 1, 3)
-- ;


-- drop table if exists kari;

SELECT version();
SELECT postgis_full_version();
SELECT pgr_version();