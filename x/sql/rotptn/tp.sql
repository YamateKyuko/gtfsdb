-- トポロジカルソートのテスト

do $$
declare
  result text[] := '{}';
  cur_node text;
begin
  -- スキーマを作成（存在しない場合のみ）
  create schema if not exists tptest;

  -- 既存テーブルを削除（何度でも安全に実行できる）
  drop table if exists tptest.edges cascade;
  drop table if exists tptest.indeg cascade;

  -- エッジテーブル作成（from_node -> to_node）
  create table if not exists tptest.edges (
    from_node text,
    to_node   text
  );

  -- テスト用データ挿入（例: a,b,c,d,e と a,b,f,e）
  insert into tptest.edges (from_node,to_node) values
    ('a','b'), ('b','c'), ('c','d'), ('d','e'),
    ('a','b'), ('b','f'), ('f','e');

  -- 入次数テーブル作成
  create table if not exists tptest.indeg (
    node text primary key,
    deg  int
  );

  -- ノード一覧と入次数を計算して挿入
  insert into tptest.indeg (node, deg)
  select n.node, coalesce(d.deg,0)
  from (
    select distinct from_node as node from tptest.edges
    union
    select distinct to_node   as node from tptest.edges
  ) n
  left join (
    select to_node as node, count(*) as deg from tptest.edges group by to_node
  ) d using (node);

  -- kahn のアルゴリズム本体
  loop
    -- 入次数0のノードを取得（安定化のため名前順）
    select node into cur_node
    from tptest.indeg
    where deg = 0
    order by node
    limit 1;

    exit when not found;

    result := array_append(result, cur_node);

    -- cur_node の出辺に応じて隣接ノードの入次数を減らす
    update tptest.indeg
    set deg = tptest.indeg.deg - sub.c
    from (
      select to_node as t, count(*) as c
      from tptest.edges
      where from_node = cur_node
      group by to_node
    ) sub
    where tptest.indeg.node = sub.t;

    -- cur_node の出辺を削除し、cur_node を indeg から削除
    delete from tptest.edges where from_node = cur_node;
    delete from tptest.indeg  where node = cur_node;
  end loop;

  -- サイクルや孤立ノードが残っている場合は末尾に追加（任意順）
  for cur_node in select node from tptest.indeg order by node loop
    result := array_append(result, cur_node);
  end loop;

  -- 結果を表示
  raise notice 'topological order: %', result;

  -- 後片付け（テーブルを削除してスキーマは残す）
  drop table if exists tptest.edges cascade;
  drop table if exists tptest.indeg cascade;
end;
$$ language plpgsql;