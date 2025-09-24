

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

