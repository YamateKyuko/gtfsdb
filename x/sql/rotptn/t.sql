
create schema if not exists tst;
CREATE OR REPLACE FUNCTION topo_sort_sequences() RETURNS text[] AS $$
DECLARE
  result text[] := '{}';
  cur_node text;
BEGIN
  
  drop table if exists tst.tns;
  create table tst.tns(v text, i integer, n integer);
  insert into tst.tns values ('a', 1), ('b', 1), ('c', 1), ('d', 1), ('e', 1);
  insert into tst.tns values ('a', 2), ('b', 2), ('f', 2), ('e', 2);
  insert into tst.tns values ('b', 3), ('f', 3), ('e', 3);
  insert into tst.tns values ('b', 4), ('f', 4), ('g', 4);
  -- insert into tst.tns values ('b', 3), ('f', 3), ('e', 3);
  with a as (select row_number() over(partition by i), v, i from tst.tns)
  update tst.tns set n = row_number from a where tns.v = a.v and tns.i = a.i;
  drop table if exists tst.tedges;
  CREATE TABLE tst.tedges(from_node text, to_node text);
  -- ここに順序制約（隣接ペア）を入れる
  insert into tst.tedges
  select distinct on (v1, v2) t1.v as v1, t2.v as v2 from tst.tns as t1 inner join tst.tns as t2 on t1.n + 1 = t2.n and t1.i = t2.i;
  -- INSERT INTO tst.tedges VALUES
  --   ('a','b'), ('b','c'), ('c','d'), ('d','e'),
  --   ('a','b'), ('b','f'), ('f','e');

  -- ノードと入次数テーブルを作る
  CREATE TEMP TABLE indeg(node text PRIMARY KEY, deg int, i integer) ON COMMIT DROP;
  INSERT INTO indeg(node, deg)
  SELECT n.node, COALESCE(d.deg, 0)
  FROM (
    SELECT DISTINCT from_node AS node FROM tst.tedges
    UNION
    SELECT DISTINCT to_node   AS node FROM tst.tedges
  ) n
  LEFT JOIN (
    SELECT to_node AS node, count(*) AS deg FROM tst.tedges GROUP BY to_node
  ) d ON n.node = d.node;

  LOOP
    -- 入次数0のノードをアルファベット順で1つ取得
    SELECT node INTO cur_node
    FROM indeg
    WHERE deg = 0
    ORDER BY node
    LIMIT 1;

    EXIT WHEN NOT FOUND;

    result := array_append(result, cur_node);

    -- そのノードを除去（出辺に応じて隣接ノードの入次数を減らす）
    UPDATE indeg SET deg = indeg.deg - sub.c
    FROM (
      SELECT to_node AS t, count(*) AS c FROM tst.tedges WHERE from_node = cur_node GROUP BY to_node
    ) sub
    WHERE indeg.node = sub.t;

    DELETE FROM tst.tedges WHERE from_node = cur_node;
    DELETE FROM indeg WHERE node = cur_node;
  END LOOP;

  -- サイクル等で残っているノードを（任意順で）追加
  FOR cur_node IN SELECT node FROM indeg LOOP
    result := array_append(result, cur_node);
  END LOOP;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 実行例
SELECT topo_sort_sequences();

select * from tst.tedges;

