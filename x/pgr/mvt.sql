-- with e as (select st_tileenvelope(12, 3635, 1612) as e),
-- envelope as (select e as e1, st_transform(e, 4326) as e2 from e)
-- select st_asmvt(t.*)
-- from (
--   select st_asmvtgeom(
--     st_transform(map.results.geom, 3857),
--     e1,
-- 		extent => 4096,
-- 		buffer => 64
--   ), 'mvtpolys'
-- 	from map.results, envelope
--   where geom && e2
-- 	) as t
-- ;




-20037508.342789, 20037508.342789





do $$
declare
val float;
level integer;
begin
select 20037508.342789 into val;

select * from map.results

select st_transform('LINESTRING(-20037508.342789 -20037508.342789,20037508.342789 20037508.342789)'::geometry(linestring, 3857), 4326)
end;
$$;