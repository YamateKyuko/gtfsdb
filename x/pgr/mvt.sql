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




-- -20037508.342789, 20037508.342789

drop type IF EXISTS floatrange CASCADE;
CREATE TYPE floatrange AS RANGE (
    SUBTYPE = float
    -- [ , SUBTYPE_OPCLASS = subtype_operator_class ]
    -- [ , COLLATION = collation ]
    -- [ , CANONICAL = canonical_function ]
    -- [ , SUBTYPE_DIFF = subtype_diff_function ]
    -- [ , MULTIRANGE_TYPE_NAME = multirange_type_name ]
);


do $$
declare
val float;
level integer;

rag as record;
begin

select 14 into level;
select 20037508.342789 / (2 ^ (level - 2)) into val;


-- select
-- floatrange(st_xmin(b), st_xmax(b), '[]') as xr,
-- floatrange(st_ymin(b), st_ymax(b), '[]') as yr
-- into rag
-- from (
--   select st_extent(geom) as b from map.results
-- ) as t;

  with extent as (
    select
      st_extent(
        st_transform(geom, 3857)
      ) as e
    from map.results),
  basetile as (
    select
      st_tileenvelope(0,0,0) as b),
  tileedge as (
    select
      ((st_xmax(b) - st_xmin(b)) / (2 ^ level)) as xh,
      ((st_ymax(b) - st_ymin(b)) / (2 ^ level)) as yh
    from basetile),
  xseri as (
    select
      generate_series(
        st_floor(st_xmin(e) / xh) + (2 ^ level / 2),
        st_ceil(st_xmax(e) / xh) + ((2 ^ level / 2) - 1)
      ) as x
    from tileedge, extent),
  yseri as (
    select
      generate_series(
        st_floor(st_ymin(e) / yh) + (2 ^ level / 2),
        st_ceil(st_ymax(e) / yh) + ((2 ^ level / 2) - 1)
      ) as y
    from tileedge, extent)

  select x, y from xseri outer join yseri;



-- select st_transform('LINESTRING(-20037508.342789 -20037508.342789,20037508.342789 20037508.342789)'::geometry(linestring, 3857), 4326)
end;
$$;











