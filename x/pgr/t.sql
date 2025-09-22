

-- select st_astext(geom) from map.edges;


-- select 
-- st_astext(st_buffer(
--   'multilinestring((0 0, 0 1), (0 1, 0 2))', 0.5, 0
-- ))

-- select * from stop_patterns where pattern_id = 414; 

-- select * from stop_patterns where pattern_id = 410;

-- select * from map.results;

-- select * 
-- from (
-- values 
--   (1, 'point(0 0)'),
--   (2, 'point(1 0)'),
--   (3, 'point(2 0)')
-- ) as t(id, geom)
-- where st_dwithin(coalesce(t.geom::geometry, 'point empty'::geometry), 'point(0 0)'::geometry, 3) and
-- not st_dwithin(coalesce(t.geom::geometry, 'point empty'::geometry), 'point(0 0)'::geometry, 1)
-- ;


-- select * from stop_patterns where pattern_id in (410, 411);

-- select *
-- from pgr_bdDijkstracost(
--     $$
--       SELECT id, source, target, (length * multiplier * indivmultiplier) as cost, (length * multiplier * indivmultiplier) as reverse_cost, capacity, reverse_capacity FROM map.edges where source is not null
--     $$,
--     13,
--     14
-- )


drop table if exists map.pattern_map;
create table map.pattern_map (
  id serial primary key,
  pattern_id integer not null,
  geom geometry(LineString, 4326),
  name text
);

drop table if exists map.mvts;
create table map.mvts (
  file bytea
);



  with extent as (
    select
      st_extent(
        st_transform(geom, 3857)
      ) as e
    from map.results),
  basetile as (
    select
      st_transform(st_tileenvelope(0,0,0), 3857) as b),
	baseedge as (
    select
      (st_xmax(b) - st_xmin(b)) as xh,
      (st_ymax(b) - st_ymin(b)) as yh
    from basetile),
  tileedge as (
    select
      (xh / (2 ^ 14)) as xth,
      (yh / (2 ^ 14)) as yth
    from baseedge),
  xseri as (
    select
      generate_series(
				(floor((st_xmin(e) + (xh / 2)) / xth))::integer,
        (floor((st_xmax(e) + (xh / 2)) / xth))::integer
      ) as x
    from tileedge, extent, baseedge),
  yseri as (
    select
      generate_series(
				(floor((-st_ymax(e) + (yh / 2)) / yth))::integer,
        (floor((-st_ymin(e) + (yh / 2)) / yth))::integer
      ) as y
    from tileedge, extent, baseedge),
  tiles as (
    select x, y, st_tileenvelope(14, x, y) as tile from xseri cross join yseri
  ),
  mvtgeoms as (
    select
      x, y,
      st_asmvtgeom(st_transform(geom, 3857), tile, 4096, 256) as mvtg,
      pattern_id
    from tiles, map.results
    where tile && st_transform(geom, 3857)
  )

  insert into map.mvts(file)
  select st_asmvt(
    mvtgeoms,
    'map', -- name (layer)
    4096, -- extent
    'mvtg', -- geom_name
    'pattern_id'
  ) from mvtgeoms
  group by x, y;

