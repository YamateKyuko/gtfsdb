/*
  見やすいバス路線図制作クエリ
    ダイクストラ法を用いて各辺にコストを設定し、
    同じ道路を通るバス路線が重ならずに見やすく表示されるようにします。

    by Yamakyu
*/

-- 2回ダイクストラ編


-- #region テーブル定義
drop table if exists map.edges;

drop table if exists map.vertices;

drop table if exists map.results;

CREATE TABLE
  map.edges (
    id integer generated always as IDENTITY,
    source BIGINT,
    target BIGINT,
    length FLOAT not null,
    capacity BIGINT DEFAULT 100,
    reverse_capacity BIGINT DEFAULT 100,
    x1 FLOAT,
    y1 FLOAT,
    x2 FLOAT,
    y2 FLOAT,
    geom geometry,
    old_id BIGINT,
    type varchar(16),
    multiplier float not null,
    indivmultiplier float not null default 1.0,
    pattern_id integer,
    feed_id integer,
    route_id varchar(256),
    deg float,
    apprmul float
  );

create table
  map.vertices (
    id integer generated always as IDENTITY,
    in_edges BIGINT[],
    out_edges BIGINT[],
    x FLOAT,
    y FLOAT,
    geom geometry
  );

create table
  map.results (
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
    route_id varchar(256),
    length float,
    segm_id integer
  );

drop table if exists map.pts;

create table -- つかってるヨ!!!
  map.pts (
    geom geometry (Point, 4326),
    type varchar(63),
    pattern_id integer,
    stop_sequence integer
  );


drop table if exists map.dcosts;
create table map.dcosts (
  id integer generated always as IDENTITY,
  pattern_id integer,
  p_stop_sequence integer,
  stop_sequence integer,
  start_vid integer,
  end_vid integer,
  cost integer
);

-- drop table if exists map.dres;
-- create table map.dres (

-- );

-- #endregion 

do $$
  -- 変数定義
  declare 
    ptn1 record;  -- パターン用
    pptn integer;  -- 前のパターンid

    stp1 record;  
    stp2 record;
    bdist float := 0.00025; -- バッファ距離

    lengthMultiplier float := 100000; -- st_lengthで出た値に必ずかけること。

    svids integer[];
    evids integer[];
    fvids integer[];

    shortest record;

    nid record;

    bool boolean;
    dres record;
    dpnode integer;
  begin

    select 0.00025 into bdist;
    select 10000000 into lengthMultiplier;

    /*
      パターンごとに繰り返し
    */
    for ptn1 in (
      select *
      from trip_patterns
      -- where route_name in (
      --   -- '府７５'
      --   '武７１'
      -- )
      where feed_id = 1 and pattern_id in (410, 411, 412, 413)
    ) loop
      raise notice 'pattern_id: %', ptn1.pattern_id;

      /*
        エッジをテーブルに挿入しコストをいじる
      */
      -- #region

      -- #region 元の路線を辺リストに挿入
      insert into map.edges (
        type,
        pattern_id,
        feed_id,
        route_id,
        geom,
        deg,
        length,
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
        st_length(geom) * lengthMultiplier as length,
        1.00 as multiplier
      from lines;
      -- #endregion


      -- #region 同じ系統のバス路線は同じ場所を走らせる
      -- with reses as (select edge as id from map.results where feed_id = ptn1.feed_id and route_id = ptn1.route_id)
      -- update map.edges set indivmultiplier = 0.0000001 where id in (select id from reses);
      -- with geoms as (select st_collect(geom) as g from map.results where feed_id = ptn1.feed_id and route_id = ptn1.route_id)
      -- update map.edges set indivmultiplier = 0.00001 from geoms where st_dwithin(
      --   coalesce(geoms.g, 'point empty'::geometry(point, 4326)),
      --   map.edges.geom,
      --   bdist*0.05
      -- );
      -- #endregion


      -- update map.edges set type = 'aanpafo' where id in (select id from reses);

      -- raise notice '%', (select array_to_string(array_agg(id::text), '-', '*') from map.edges where not indivmultiplier = 1);
      -- raise notice '%', (select array_to_string(array_agg(id::text), '-', '*') from (select edge as id from map.results where feed_id = ptn1.feed_id and route_id = ptn1.route_id));

      -- #region 決定した路線の周辺のエッジを通さないようにする
      update
        map.edges
      set

        -- (apprmul, type) = (100, 'aaa')

        (multiplier, type) = (
          (map.edges.multiplier * 10) + (
            map.edges.multiplier *
            1000 *
            abs(sin(st_angle(
              map.edges.geom,
              map.results.geom
          )))),
          'aaa'
        )

      from map.results
      where
        (map.results.pattern_id = pptn) and
        -- ((map.edges.pattern_id = pptn and type in ('外郭', '分割')) or 
        -- (map.edges.pattern_id = ptn1.pattern_id and type = '路線')) and
        st_dwithin(
          map.results.geom,
          map.edges.geom,
          bdist*0.2
        );
      -- #endregion

      -- #endregion
      

      

      /*
        ダイクストラにかけるエッジの前処理
      */
      -- #region

      -- #region 重複エッジ分割
      insert into map.edges (
        old_id,
        geom,
        multiplier,
        type,
        length
      )
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
      SELECT
        row_number() over()::integer as seq,
        geom,
        1000000000,
        '重分割',
        1
      from collection;
      -- #endregion

      -- #region 交差エッジ分割
      insert into map.edges (
        old_id,
        geom,
        type,
        multiplier,
        length
      )
      select id, geom, '分割', 100000000, 1
      from pgr_separateCrossing('SELECT id, geom FROM map.edges', 0.00000001);
      -- #endregion

      -- #region 新規エッジ通過コスト挿入
      with costs as (
        select
          e2.id,
          ST_Length(e2.geom) * lengthMultiplier as length,
          e1.multiplier, -- 分割元から取得
          e1.indivmultiplier
        from map.edges as e1
        inner join map.edges as e2 on (e1.id = e2.old_id)
      )
      UPDATE map.edges as e SET (
        length,
        multiplier,
        indivmultiplier
      ) = (
        c.length,
        c.multiplier,
        c.indivmultiplier
      )
      FROM costs AS c WHERE e.id = c.id;
      -- #endregion

      -- #region 不足する頂点を新規に作成
      with new_vertex as (
        select ev.*
        from pgr_extractVertices('select id, geom from map.edges where source is null or target is null') ev
        left join map.vertices v using(geom)
        where v is null
      )
      insert into map.vertices (in_edges, out_edges, x, y, geom)
      select in_edges, out_edges,x,y,geom from new_vertex;
      -- #endregion

      -- #region エッジ始点側頂点情報更新
      update map.edges as e
      set
        source = v.id,
        x1 = x,
        y1 = y      from map.vertices as v
      where source is null and ST_StartPoint(e.geom) = v.geom;
      -- #endregion

      -- #region エッジ終点側頂点情報更新
      update map.edges as e
      set
        target = v.id,
        x2 = x,
        y2 = y
      from map.vertices as v
      where target is null and ST_EndPoint(e.geom) = v.geom;
      -- #endregion

      -- 分割などが行われたエッジの元を削除して軽量化
      delete from map.edges where id in (select old_id from map.edges where old_id is not null);
      -- 前処理済みエッジの判別に使うold_idを削除
      update map.edges set old_id = null where old_id is not null;

      -- #endregion


      /*
        各バス停間ごとにダイクストラ法で経路を求める
      */
      -- #region
      for stp1 in (select * from stop_patterns where pattern_id = ptn1.pattern_id) loop
        raise notice '  stop_sequence: %', stp1.stop_sequence;

        -- #region 起点側バス停を取得
        if (stp1.stop_sequence = 1) then 
          -- 最初のバス停は処理せず次から
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
            bdist * 5
          )
          and not st_dwithin(
            coalesce((select st_collect(geom) from map.results where not (stp1.feed_id = feed_id and stp1.route_id = route_id) ), 'point empty'::geometry(point, 4326)),
            -- coalesce(, 'point empty'::geometry(point, 4326)),
            map.vertices.geom,
            bdist * 0.2
          );
          select svids into fvids;
        end if;
        -- #endregion


        -- #region 終点側バス停を取得
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
          bdist * 5
        )
        and not st_dwithin(
          coalesce((select st_collect(geom) from map.results where not (stp1.feed_id = feed_id and stp1.route_id = route_id)), 'point empty'::geometry(point, 4326)),
          -- coalesce(, 'point empty'::geometry(point, 4326)),
          map.vertices.geom,
          bdist * 0.2
        );
        -- #endregion

        -- #region 各バス停間ごとに最短経路を求める
        insert into map.dcosts (pattern_id, p_stop_sequence, stop_sequence, start_vid, end_vid, cost)
        select stp1.pattern_id, stp1.stop_sequence - 1, stp1.stop_sequence, start_vid, end_vid, agg_cost
        -- into strict shortest
        from pgr_Dijkstracost(
          'SELECT id, source, target, (length * multiplier * indivmultiplier) as cost, (length * multiplier * indivmultiplier * 5) as reverse_cost, capacity, reverse_capacity FROM map.edges',
          svids,
          evids
        )
        order by agg_cost asc;
        --#endregion

        select evids into svids;

        -- #region コメントアウト
        /*
        -- #region 停留所挿入
        insert
        into map.pts (
          geom,
          pattern_id,
          stop_sequence
        )
        select
          geom,
          ptn1.pattern_id,
          stp1.stop_sequence
        from map.vertices
        where id = shortest.end_vid;
        -- #endregion

        -- #region ダイクストラ法
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
          route_id,
          length
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
          stp1.route_id,
          map.edges.length
        from pgr_Dijkstra(
          'SELECT id, source, target, (length * multiplier * indivmultiplier) as cost, (length * multiplier * indivmultiplier * 5) as reverse_cost, capacity, reverse_capacity FROM map.edges',
          (select shortest.start_vid), -- 出発点の頂点ID
          (select shortest.end_vid) -- 到着点の頂点ID
        ) as res
        inner join map.edges on (edge = map.edges.id);
        -- #endregion

        -- #region 短絡
        if (
          select
            case when count(*) >= 3 then true
            else false end
          from map.results
          where
            pattern_id = ptn1.pattern_id and
            sequence = stp1.stop_sequence
        ) then
          with reses as (
            select * from map.results where pattern_id = ptn1.pattern_id and sequence = stp1.stop_sequence
          ),
          aggcost as (
            select sum(length) as l from reses
          ),
          shortestlength as (
            select
              st_distance(
                (select geom from map.vertices where id = shortest.start_vid),
                (select geom from map.vertices where id = shortest.end_vid)
              ) * lengthMultiplier as l
          )
          select ((select l from shortestlength) * 10 < (select l from aggcost)) into bool;
          if (bool) then
            delete from map.results where pattern_id = ptn1.pattern_id and sequence = stp1.stop_sequence;
            insert into map.edges (
              type,
              pattern_id,
              feed_id,
              route_id,
              geom,
              length,
              multiplier,
              source,
              target
            )
            select
              '短絡' as type,
              ptn1.pattern_id,
              ptn1.feed_id,
              ptn1.route_id,
              geom,
              st_length(geom) * lengthmultiplier as length,
              1 as multiplier,
              shortest.start_vid,
              shortest.end_vid
            from (
              select st_makeline(
                (select geom from map.vertices where id = shortest.start_vid),
                (select geom from map.vertices where id = shortest.end_vid)
              ) as geom
            )
            returning * into nid;

            insert into map.results (
              seq,
              path_seq,
              node,
              edge,
              cost,
              agg_cost,
              geom,
              sequence,
              pattern_id,
              feed_id,
              route_id,
              length
            )
            select
              null as seq,
              null as path_seq,
              shortest.start_vid,
              nid.id,
              nid.length,
              0,
              nid.geom,
              stp1.stop_sequence,
              stp1.pattern_id,
              stp1.feed_id,
              stp1.route_id,
              nid.length
            ;
          end if;
        end if;
        -- #endregion
        */
        -- #endregion

        select stp1 into stp2;
      end loop;
      -- #endregion


      select * into shortest
      from pgr_Dijkstracost(
        $d$SELECT id, start_vid as source, end_vid as target, cost FROM map.dcosts;$d$,
        fvids,
        evids
      )
      order by agg_cost asc
      limit 1;

      for dres in (
        select
          *
        from pgr_Dijkstra(
          $d2$SELECT id, start_vid as source, end_vid as target, cost, cost as reverse_cost FROM map.dcosts$d2$,
          (select shortest.start_vid), -- 出発点の頂点ID
          (select shortest.end_vid) -- 到着点の頂点ID
        ) as res
      ) loop

        insert into map.pts (
          geom,
          pattern_id,
          stop_sequence
        )
        select
          geom,
          ptn1.pattern_id,
          dres.seq
        from map.vertices
        where id = dres.node;

        if (dres.seq = 1) then
          select dres.node into dpnode;
          continue;
        end if;
        raise notice '%', dres.seq;
      
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
          route_id,
          length
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
          stp1.route_id,
          map.edges.length
        from pgr_Dijkstra(
          $d2$SELECT id, source, target, (length * multiplier * indivmultiplier) as cost, (length * multiplier * indivmultiplier * 5) as reverse_cost, capacity, reverse_capacity FROM map.edges$d2$,
          (select dpnode), -- 出発点の頂点ID
          (select dres.node) -- 到着点の頂点ID
        ) as res
        inner join map.edges on(edge = map.edges.id);

        

        select dres.node into dpnode;
      end loop;

      delete from map.dcosts;




      -- 路線外郭
      insert into map.edges (
        type,
        pattern_id,
        feed_id,
        route_id,
        geom,
        deg,
        length,
        multiplier
      )
      with segm as (
        select
          '外郭' as type,
          ptn1.pattern_id as pattern_id,
          0.75 as multiplier,
          ((st_dumpsegments(
            st_forcepolygoncw(st_buffer(
              st_linemerge(st_collect(geom))
            , bdist, 'quad_segs=1 join=mitre mitre_limit=5.0'))
          )).geom) as geom
        from map.results
        where map.results.pattern_id = ptn1.pattern_id
      ),
      aaa as (
        select
          '外郭' as type,
          ptn1.pattern_id as pattern_id,
          0.75 as multiplier,
          ((st_dumpsegments(
            st_forcepolygoncw(st_buffer(geom, bdist, 'quad_segs=1 join=mitre mitre_limit=5.0 endcap=flat'))
          )).geom) as geom
        from map.results
        where map.results.pattern_id = ptn1.pattern_id
      ),
      bbb as (
        select * from segm
        union
        select * from aaa
      )
      select
        segm.type,
        pattern_id,
        feed_id,
        route_id,
        geom,
        st_azimuth(st_startpoint(geom), st_endpoint(geom)) as deg,
        st_length(geom) * lengthMultiplier as length,
        segm.multiplier
      from bbb as segm
      inner join trip_patterns using(pattern_id);


      select ptn1.pattern_id into pptn;

      update map.edges set indivmultiplier = 1.0 where not indivmultiplier = 1.0;
    end loop;
  end;
$$;

-- select * , st_astext(geom) from map.edges;
-- select * from map.edges where id = 23;
select
  *
from
  map.results;

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
select
  *
from
  map.edges;