drop table if exists map.edges;
drop table if exists map.vertices;
drop table if exists map.results;

CREATE TABLE map.edges (
    id integer generated always as IDENTITY,
    source BIGINT,
    target BIGINT,
    cost FLOAT,
    reverse_cost FLOAT,
    capacity BIGINT DEFAULT 100,
    reverse_capacity BIGINT DEFAULT 100,
    x1 FLOAT,
    y1 FLOAT,
    x2 FLOAT,
    y2 FLOAT,
    geom geometry,
    old_id BIGINT,
    type varchar(16),
    multiplier float DEFAULT 1.0,
    pattern_id integer,
    feed_id integer,
    route_id varchar(256),
    -- p1 geometry(Point, 4326),
    -- p2 geometry(Point, 4326),
    deg float

);

create table map.vertices (
  id integer generated always as IDENTITY,
  in_edges BIGINT[],
  out_edges BIGINT[],
  x FLOAT,
  y FLOAT,
  geom geometry
);

create table map.results (
  seq integer,
  path_seq integer,
  start_vid integer,
  end_vid integer,
  node integer,
  edge integer,
  cost float,
  agg_cost float,
  geom geometry,
  sequence integer,
  pattern_id integer,
  feed_id integer,
  route_id varchar(256)
);












do $$
  declare 
    ptn1 record;
    pptn integer;

    stp1 record;
    stp2 record;
    bdist float := 0.001; -- バッファ距離

    svids integer[];
    evids integer[];

    shortest record;
  begin 

  select 0.001 into bdist;

    for ptn1 in (
      select *
      from trip_patterns
      -- where route_name in (
      --   -- '府７５'
      --   '武７１'
      -- )
      where pattern_id in (410, 411)
    ) loop

      -- 路線
      insert into map.edges (
        type,
        pattern_id,
        feed_id,
        route_id,
        geom,
        deg,
        cost,
        reverse_cost,
        multiplier
      )
      with points as (
        select 
          '路線' as type,
          stop_patterns.pattern_id,
          stop_patterns.feed_id,
          stop_patterns.route_id,
          st_point(s1.stop_lon, s1.stop_lat, 4326) as p1,
          st_point(s2.stop_lon, s2.stop_lat, 4326) as p2
        from stop_patterns
        inner join stops as s1 on stop_patterns.feed_id = s1.feed_id and stop_patterns.stop_id = s1.stop_id
        inner join stops as s2 on stop_patterns.feed_id = s2.feed_id and stop_patterns.next_stop_id = s2.stop_id
        where 
          stop_patterns.next_stop_id is not null and
          stop_patterns.pattern_id = ptn1.pattern_id
      ),
      lines as (
        select
          type,
          pattern_id,
          feed_id,
          route_id,
          st_makeline(p1, p2) as geom,
          st_azimuth(p1, p2) as deg
        from points
      )
      select 
        *,
        st_length(geom) as cost,
        st_length(geom) as reverse_cost,
        1.00 as multiplier
      from lines;


      update
        map.edges
      set
        (multiplier, type) = (map.edges.multiplier * 100, 'aaa')
      from map.results
      where
        map.edges.pattern_id = pptn and
        st_dwithin(
          map.results.geom,
          map.edges.geom,
          bdist*0.5
        );
      

      

      -- エッジ処理

      -- 重複エッジ分割
      with edges_table as (
        select id, geom from map.edges
      ), 
      get_endpoints as (
        select
          e1.id as id1, e2.id as id2,
          e1.geom as g1, e2.geom as g2,
          (st_dumppoints(ST_Intersection(e1.geom, e2.geom))).geom as point
        from edges_table as e1, edges_table as e2
        where e1.id < e2.id and ST_overlaps(e1.geom, e2.geom)
      ),
      crossings as (
        select id1, g1, point from get_endpoints
        union
        select id2, g2, point from get_endpoints
      ),
      blades as (
        select id1, g1, ST_UnaryUnion(ST_Collect(point)) AS blade
        from crossings
        where not(point = st_startpoint(g1) or point = st_endpoint(g1))
        group by id1, g1
      ),
      collection AS (
        SELECT id1, (st_dump(st_split(st_snap(g1, blade, 0.01), blade))).*
        FROM blades
      )
      insert into map.edges (
        old_id,
        -- id,
        geom
      )
      SELECT
        row_number() over()::integer as seq,
        -- id1::bigint,
        -- path[1],
        geom
      FROM collection;

      -- 交差エッジ分割
      insert into map.edges (old_id, geom, type)
      select id, geom, '分割'
      from pgr_separateCrossing('SELECT id, geom FROM map.edges', 0.00001);

      update map.edges set () = ()
      from map.edges
      where
      map.edges.old_id is not null;

      -- 新規エッジ通過コスト挿入
      with costs as (
        select
          e2.id,
          ST_Length(e2.geom) as cost,
          ST_Length(e2.geom) as reverse_cost
        from map.edges as e1 
        inner join map.edges as e2 on (e1.id = e2.old_id)
      )
      UPDATE map.edges e
      SET (cost, reverse_cost) = (c.cost, c.reverse_cost)
      FROM costs AS c WHERE e.id = c.id;

      -- 不足する頂点を新規に作成
      with new_vertex as (
        select ev.*
        -- from pgr_extractvertices('SELECT id, geom FROM map.edges WHERE old_id IS NOT NULL') ev

        from pgr_extractVertices('select id, geom from map.edges where source is null or target is null') ev
        left join map.vertices v using(geom)
        where v is null
      )
      insert into map.vertices (in_edges, out_edges, x, y, geom)
      select in_edges, out_edges,x,y,geom from new_vertex;

      -- エッジ始点側頂点情報更新
      update map.edges as e
      set
        source = v.id,
        x1 = x,
        y1 = y
      from map.vertices as v
      where source is null and ST_StartPoint(e.geom) = v.geom;

      -- エッジ終点側頂点情報更新
      update map.edges as e
      set
        target = v.id,
        x2 = x,
        y2 = y
      from map.vertices as v
      where target is null and ST_EndPoint(e.geom) = v.geom;




      for stp1 in (select * from stop_patterns where pattern_id = ptn1.pattern_id) loop

        if (stp1.stop_sequence = 1) then 
          continue;
        elsif (stp1.stop_sequence = 2) then 
          with starting as (
            select
              st_point(stop_lon, stop_lat, 4326) as point
            from stop_patterns
            inner join stops using (feed_id, stop_id)
            where stop_sequence = 1 and pattern_id = stp1.pattern_id
          )
          select array_agg(id)
          into svids
          from map.vertices
          where st_dwithin(
            (select point from starting),
            map.vertices.geom,
            bdist * 2
          );
        end if;



        with ending as (
          select st_point(stop_lon, stop_lat, 4326) as point
          from stops
          where feed_id = stp1.feed_id and stop_id = stp1.stop_id
        )
        select array_agg(id)
        into evids
        from map.vertices
        where st_dwithin(
          (select point from ending),
          geom,
          bdist * 2
        );


        
        select *
        into strict shortest
        from pgr_bdDijkstracost(
          'SELECT id, source, target, cost * multiplier as cost, (reverse_cost * multiplier), capacity, reverse_capacity FROM map.edges',
          svids,
          evids
        )
        order by agg_cost asc
        limit 1;


        -- raise notice '%', shortest;
        select array[shortest.end_vid] into svids;

        -- svid_set as (select [costlist.end_vid]::integer[] into svids from costlist)

        insert into map.results (
          seq,
          path_seq,
          -- start_vid,
          -- end_vid,
          node,
          edge,
          cost,
          agg_cost,
          geom,
          sequence,
          pattern_id,
          feed_id,
          route_id
        )
        select
          seq,
          path_seq,
          -- start_vid,
          -- end_vid,
          node,
          edge,
          res.cost,
          agg_cost,
          geom,
          stp1.stop_sequence,
          stp1.pattern_id,
          stp1.feed_id,
          stp1.route_id
        from pgr_bdDijkstra(
          'SELECT id, source, target, (cost * multiplier) as cost, reverse_cost * multiplier, capacity, reverse_capacity FROM map.edges',
          (select shortest.start_vid), -- 出発点の頂点ID
          (select shortest.end_vid) -- 到着点の頂点ID
        ) as res
        inner join map.edges on (edge = map.edges.id);

        select stp1 into stp2;
      end loop;


      -- 路線外郭
      insert into map.edges (
        type,
        pattern_id,
        feed_id,
        route_id,
        geom,
        deg,
        cost,
        reverse_cost
      )
      with segm as (
        select
          '外郭' as type,
          pattern_id,
          route_id,
          feed_id,
          ((st_dumpsegments(st_buffer(geom, bdist, 1))).geom) as geom,
          0.75 as multiplier 
        from map.results
        where pattern_id = ptn1.pattern_id
      )
      select
        type,
        segm.pattern_id,
        feed_id,
        route_id,
        geom as geom,
        st_azimuth(st_startpoint(geom), st_endpoint(geom)) as deg,
        st_length(geom) as cost,
        st_length(geom) as reverse_cost
      from segm;


      select ptn1.pattern_id into pptn;
    end loop;
  end;
$$;

-- select * , st_astext(geom) from map.edges;

-- select * from map.edges where id = 23;

select * from map.results;
-- select * from map.results;


-- delete from map.results;
-- insert into map.results (seq, path_seq, end_vid)
-- select route.*, geom from pgr_bdDijkstra(
--   'SELECT id, source, target, cost, reverse_cost, capacity, reverse_capacity FROM map.edges',
--   1,
--   100
--   -- false, -- bidirectional
--   -- false, -- directed
--   -- false, -- use vertex ids
--   -- true -- return path
-- ) as route
-- inner join map.edges on (edge = map.edges.id);
