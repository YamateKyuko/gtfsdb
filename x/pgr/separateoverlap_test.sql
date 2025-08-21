drop table if exists edges;
drop table if exists vertices;

CREATE TABLE edges (
    id integer generated always as IDENTITY,
    source BIGINT,
    target BIGINT,
    cost FLOAT,
    reverse_cost FLOAT,
    capacity BIGINT,
    reverse_capacity BIGINT,
    x1 FLOAT,
    y1 FLOAT,
    x2 FLOAT,
    y2 FLOAT,
    geom geometry
);

create table vertices (
  id integer generated always as IDENTITY,
  in_edges BIGINT[],
  out_edges BIGINT[],
  x FLOAT,
  y FLOAT,
  geom geometry
);


insert into edges (geom) values 
  ('linestring(0 0, 4 4)'),
  ('linestring(2 2, 6 6)')
;
insert INTO vertices (in_edges, out_edges, x, y, geom)
select in_edges, out_edges, x, y, geom from pgr_extractVertices('SELECT id, geom FROM edges ORDER BY id');

with costs as (select st_length(geom) as cost, st_length(geom) * -1 as reverse_cost from edges)
update edges set
  (cost, reverse_cost) =
  (c.cost, c.reverse_cost)
from costs c;

ALTER TABLE edges ADD old_id BIGINT;







WITH
edges_table AS (
  SELECT id, geom FROM edges
),
-- get_overlaps AS (
--   SELECT e1.id id1, e2.id id2, e1.geom AS g1, e2.geom AS g2, ST_Intersection(e1.geom, e2.geom) AS linestring
--   FROM edges_table e1, edges_table e2
--   WHERE e1.id < e2.id AND ST_overlaps(e1.geom, e2.geom)
-- ),
-- get_endpoints as (
--   select id1, id2, g1, g2, (st_dumppoints(linestring)).geom as point
--   from get_overlaps
-- ),

get_endpoints as (

  select
    e1.id as id1, e2.id as id2,
    e1.geom as g1, e2.geom as g2,
    (st_dumppoints(ST_Intersection(e1.geom, e2.geom))).geom as point
  from edges_table as e1, edges_table as e2
  where e1.id < e2.id and ST_overlaps(e1.geom, e2.geom)


  -- select id1, id2, g1, g2, (st_dumppoints(linestring)).geom as point
  -- from get_overlaps
),

crossings AS (
  SELECT id1, g1, point FROM get_endpoints
  UNION
  SELECT id2, g2, point FROM get_endpoints
),

blades AS (
  SELECT id1, g1, ST_UnaryUnion(ST_Collect(point)) AS blade
  FROM crossings
  where not(point = st_startpoint(g1) or point = st_endpoint(g1))
  GROUP BY id1, g1
),

collection AS (
  SELECT id1, (st_dump(st_split(st_snap(g1, blade, 0.01), blade))).*
  FROM blades
)

SELECT row_number() over()::INTEGER AS seq, id1::BIGINT, path[1], geom, st_astext(geom)
FROM collection;
;