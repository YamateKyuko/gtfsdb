
select * from (values(1,1,0), (1,1,1)) as t(x,y,z);
select * from (values
(st_point(35,135,3857),'hyogo'),
(st_point(30,120,3857),'hangzhou'),
(st_point(-23.5,150,3857),'rockhampton'),
(st_point(35,-120,3857),'timberpeak')
) as t(geom,name);


select
st_asmvt()
from (select
st_asmvtgeom()

) as t