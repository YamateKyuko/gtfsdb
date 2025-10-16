-- テーブル作成
DROP TABLE IF EXISTS map.test_polygons;
CREATE TABLE map.test_polygons (
  id serial PRIMARY KEY,
  name text,
  geom geometry(Polygon, 4326)
);

-- 東京駅周辺に適当なポリゴンを挿入
INSERT INTO map.test_polygons (name, geom) VALUES
('Polygon A', ST_GeomFromText('POLYGON((139.7648 35.6812, 139.7658 35.6812, 139.7658 35.6822, 139.7648 35.6822, 139.7648 35.6812))', 4326)),
('Polygon B', ST_GeomFromText('POLYGON((139.7628 35.6802, 139.7638 35.6802, 139.7638 35.6812, 139.7628 35.6812, 139.7628 35.6802))', 4326)),
('Polygon C', ST_GeomFromText('POLYGON((139.7668 35.6822, 139.7678 35.6822, 139.7678 35.6832, 139.7668 35.6832, 139.7668 35.6822))', 4326));