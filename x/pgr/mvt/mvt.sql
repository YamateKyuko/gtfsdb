drop table if exists map.pattern_map;
create table map.pattern_map (
  id serial primary key,
  pattern_id integer not null,
  geom geometry(LineString, 4326),
  name text
);

drop table if exists map.mvts;
create table map.mvts (
  data bytea,
  x integer,
  y integer,
  z integer
);


SET bytea_output = 'hex';

with extent as (
  select
    st_extent(
      st_transform(geom, 3857)
    ) as e
  from map.results),
level as (
  select l from (values(14), (12)) as t(l)
),
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
    (xh / (2 ^ l)) as xth,
    (yh / (2 ^ l)) as yth,
    l
  from baseedge, level),
xseri as (
  select
    generate_series(
      (floor((st_xmin(e) + (xh / 2)) / xth))::integer,
      (floor((st_xmax(e) + (xh / 2)) / xth))::integer
    ) as x,
    l
  from tileedge, extent, baseedge),
yseri as (
  select
    generate_series(
      (floor((-st_ymax(e) + (yh / 2)) / yth))::integer,
      (floor((-st_ymin(e) + (yh / 2)) / yth))::integer
    ) as y,
    l
  from tileedge, extent, baseedge),
tiles as (
  select
    x,
    y,
    xseri.l as z,
    st_tileenvelope(xseri.l, x, y) as tile
    from xseri
    cross join yseri
    where xseri.l = yseri.l),
mvtgeoms as (
  select
    x, y, z,
    st_asmvtgeom(st_transform(geom, 3857), tile, 4096, 256) as mvtg,
    pattern_id
  from tiles, map.results
  where tile && st_transform(geom, 3857)
)
insert into map.mvts(data, x, y, z)
select
  st_asmvt(
    mvtgeoms, -- row
    'map' -- name (layer)
    -- 4096, -- extent
    -- 'mvtg', -- geom_name
    -- 'pattern_id'
  ),
  x,
  y,
  z
from mvtgeoms
group by x, y, z;

