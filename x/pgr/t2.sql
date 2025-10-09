with tilenums as (
select * from (values(1,1,0), (1,1,1)) as t(z,x,y)
)
points as (
select * from (values
(st_point(35,135,3857),'nishiwaki'),
(st_point(40,140,3857),'noshiro'),
(st_point(30,120,3857),'hangzhou'),
(st_point(-23.5,150,3857),'rockhampton'),
(st_point(35,-120,3857),'timberpeak')
) as t(geom,name)
)

select
st_asmvt(
t,
'polys'
)
from (
select
st_asmvtgeom(grom,st_tileenvelope(1,1,0)),
from points
where geom && st_tileenvelope(1,1,0)

) as t