-- select * from stop_patterns where route_name = '調３４' order by pattern_id, stop_sequence;
select * from stop_patterns where route_name = '府４６' order by pattern_id, stop_sequence;
-- select * from daytype_cnt where pattern_id in (select pattern_id from trip_patterns where route_name = '府４２')
-- select * from stops limit 100;
-- order by cnt desc;
-- select * from stop_patterns ;
-- delete from parent_stations;
-- select * from translations where field_name = 'route_short_name' limit 100;
-- 晴海町->府中 direction_id
-- select * from stop_times inner join trips using(trip_id) where stop_sequence = 1 and route_id = '443' limit 1;
-- select stop_name, stop_sequence, direction_id, route_id, trip_id from stop_times
-- inner join stops using (feed_id, stop_id) 
-- inner join trips using(feed_id, trip_id)
-- where trip_id in ('06_01_0981_05_004452', '06_01_0081_13_004431')
-- order by trip_id, stop_sequence;

-- 京王バス 
-- service_id ww_WW_OO
-- ww 曜日 (平日, 土曜, 休日)
-- WW 01, 02, 03 (平日, 土曜, 休日)

-- trip_id OO_SS_NNNN_PP_RRRRRD
-- OO office_id
-- WW 01, 02, 03 (平日, 土曜, 休日)
-- PP pattern (多分)
-- NNNN 番号 (多分)
-- RRRRR route_id
-- D direction_id + 1

-- 01 八王子
-- 02 なし
-- 03 中野
-- 04 永福町
-- 05 調布
-- 06 府中
-- 07 桜ヶ丘
-- 08 南大沢
-- 09 小金井
-- 10 高尾
-- 11 桜ヶ丘
-- 12 なし
-- 13 小金井

-- select route_name from trips inner join routes using(feed_id, route_id)
-- -- where trip_id ~ '(^06_01_)(0981)(.*)(0044..$)'
-- where 
-- feed_id = 1 and
-- trip_id ~ '(^.)(.*)(_03_)(0.....$)'
-- group by route_name;

-- select * from trips where direction_id is null and feed_id = 3;
-- select distinct on (route_id) route_id, route_name, trip_id, trips.direction_id, service_id, count(*) over(partition by route_id)  from routes inner join trips using (feed_id, route_id)
-- where feed_id = 1 and trip_id ~ '^06_01_...._.._.0445.';
-- select * from stop where feed_id = 1 and stop_id ~ '(^0622)(.*)';
-- select stop_name from stop_times inner join stops using(feed_id, stop_id) where trip_id = '06_01_5131_08_004442' order by stop_sequence;
-- select count(*) from routes where feed_id = 1 and (CASE WHEN route_id ~ '[0-9]' THEN to_number(route_id, '9999') else 0 END) % 3 = 0;
-- with a as (select *, '' || lpad(jp_office_id, 2, '0') || '_.._...._.._' || lpad(route_id, 5, '0') || (direction_id + 1) || '' as ptn from trips where feed_id = 1 and route_id != '1072')
-- select ptn, * from a where regexp_match(route_id, '' || lpad(jp_office_id, 2, '0') || '_.._...._.._' || lpad(route_id, 5, '0') || (direction_id + 1) || '') is not null;


-- select * from trips where feed_id = 1 and trip_id = '06_03_0622_11_010212' and trip_id !~ '06_.._...._.._010212';

-- select pattern_id, trip_id from trips
-- select stop_sequence, stop_name, trip_id, direction_id from trips inner join stop_times using(feed_id, trip_id) inner join stops using(feed_id, stop_id) where trips.pattern_id = 361 order by trip_id, stop_sequence limit 100; 
-- select stop_sequence, stop_name, trip_id, direction_id from trips inner join stop_times using(feed_id, trip_id) inner join stops using(feed_id, stop_id) where trips.pattern_id = 362 order by trip_id, stop_sequence limit 100;