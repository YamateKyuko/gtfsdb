-- セグメント化と route->segment テーブル作成（例）
-- 前提: table routes(id int, geom geometry(LineString,4326))
drop table if exists tmp.segments cascade;
drop table if exists tmp.route_segments cascade;

create schema if not exists tmp;

-- 1) 全ての交点で分割してセグメント化
create table tmp.segments as
with geo as (
  select 
    pattern_id as id,
    st_makeline(st_point(stop_lon, stop_lat, 4326) order by stop_sequence) as geom
  from stop_patterns inner join stops using(feed_id, stop_id) group by pattern_id
),
exploded as (
  select id, (st_dump(st_segmentize(st_transform(geom,3857), 10))).geom as geom3857
  from geo
),
-- st_segmentize は長い線を短い分割にする簡易処理。より正確には st_split を交点集合で使う。
segments as (
  select 
    row_number() over() as segment_id,
    st_transform(geom3857,4326) as geom
  from exploded
)

select segment_id, geom from segments;

-- 2) route と segment の交差で対応を作る
create table tmp.route_segments as
select r.id as route_id, s.segment_id
from routes r
join tmp.segments s
  on st_intersects(st_transform(r.geom,4326), s.geom);

-- インデックス
create index on tmp.segments using gist (geom);
create index on tmp.route_segments(route_id);
create index on tmp.route_segments(segment_id);

-- 3) 書き戻し用テーブル（最終結果）
drop table if exists tmp.segment_lanes;
create table tmp.segment_lanes (
  segment_id int,
  route_id int,
  lane int
);