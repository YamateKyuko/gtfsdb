

-- select st_astext(geom) from map.edges;


-- select 
-- st_astext(st_buffer(
--   'multilinestring((0 0, 0 1), (0 1, 0 2))', 0.5, 0
-- ))

select * from stop_patterns where pattern_id = 414; 

select * from stop_patterns where pattern_id = 410;