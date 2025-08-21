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
  -- ('linestring(3 3, 5 5)')
  ('linestring(0 2, 2 0)')
  -- ('linestring(-1 -1, 0 0)')
;

insert INTO vertices (in_edges, out_edges, x, y, geom)
select in_edges, out_edges, x, y, geom from pgr_extractVertices('SELECT id, geom FROM edges ORDER BY id');

with costs as (select st_length(geom) as cost, st_length(geom) * -1 as reverse_cost from edges)
update edges set
  (cost, reverse_cost) =
  (c.cost, c.reverse_cost)
from costs c;

ALTER TABLE edges ADD old_id BIGINT;

INSERT INTO edges (old_id, geom)
SELECT id, geom
FROM pgr_separateCrossing('SELECT id, geom FROM edges');

WITH
costs AS (
  SELECT
    e2.id,
    ST_Length(e2.geom) AS cost,
    -1 * ST_Length(e2.geom) AS reverse_cost
  FROM edges e1 JOIN edges e2 ON (e1.id = e2.old_id)
)
UPDATE edges e
SET (cost, reverse_cost) = (c.cost, c.reverse_cost)
FROM costs AS c WHERE e.id = c.id;

WITH
new_vertex AS (
  SELECT ev.*
  FROM pgr_extractVertices('SELECT id, geom FROM edges WHERE old_id IS NOT NULL') ev
  LEFT JOIN vertices v using(geom)
  WHERE v IS NULL)
INSERT INTO vertices (in_edges, out_edges,x,y,geom)
SELECT in_edges, out_edges,x,y,geom FROM new_vertex;

UPDATE edges AS e
SET source = v.id, x1 = x, y1 = y
FROM vertices AS v
WHERE source IS NULL AND ST_StartPoint(e.geom) = v.geom;

UPDATE edges AS e
SET target = v.id, x2 = x, y2 = y
FROM vertices AS v
WHERE target IS NULL AND ST_EndPoint(e.geom) = v.geom;

select * from vertices;
select *, st_astext(geom) from edges;


drop table if exists edges;
drop table if exists vertices;