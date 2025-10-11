with tilenums as (
  select
    *
  from (values
    (1,1,0)
    -- (1,1,1)
  ) as t(z,x,y)
),
points as (
  select
    -- st_setsrid(geom, 3857) as geom,
    geom,
    name
  from (values
    (st_point(135,35,4326),'nishiwaki')
    -- (st_point(40,140,4326),'noshiro'),
    -- (st_point(30,120,4326),'hangzhou'),
    -- (st_point(-23.5,150,4326),'rockhampton'),
    -- (st_point(35,-120,4326),'timberpeak')
  ) as t(geom,name)
),
mvts as (
  select
  st_asmvt(
    t,
    'polys'
  ) as mvt
  from (
    select
      st_asmvtgeom(
        geom,
        st_tileenvelope(1,1,0)
      )
    from points
    where geom && st_tileenvelope(1,1,0)
  ) as t
)
-- select * from mvts
select btrim(mvt::TEXT, '\x') from mvts