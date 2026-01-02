-- with a as (

-- select
--   t.feed_id,
--   trans_id,
--   lang,
--   translation

-- from r.translations as t
-- left join r.stops as s on trans_id = stop_name
-- left join r.routes as r1 on trans_id = r1.route_short_name
-- left join r.stop_times as st on trans_id = stop_headsign
-- left join r.routes as r2 on trans_id = r2.route_long_name
-- where
--   lang is not null and
--   trans_id is not null and
--   s.stop_id is null and
--   r1.route_id is null and
--   r2.route_id is null and
--   st.stop_id is null
-- ),
-- b as (
--   select 
--     trans_id,
--     stop_headsign
--   from (select trans_id from a group by trans_id)
--   left join (select stop_headsign from r.stop_times group by stop_headsign)
--     on stop_headsign similar to ('%' || trans_id || '%') -- 要修正
-- )
-- select * from b inner join r.translations using (trans_id)

with a as (
  select 
    stop_headsign,
    trans_id,
    count(*) over (partition by stop_headsign) as c1
    -- array_agg(trans_id)
  from (select trans_id from r.translations group by trans_id)
  inner join (select stop_headsign from r.stop_times left join r.translations on trans_id = stop_headsign where trans_id is null group by stop_headsign )
    on stop_headsign similar to ('%' || trans_id || '%')
  -- group by stop_headsign
),
b as (
  select 
  -- *
    stop_headsign,
    j.trans_id,
    a.c1,
    count(*) as c2

  -- count(*) over(partition by stop_headsign, j.trans_id)
  from a inner join a as j using(stop_headsign)

  where
  -- a.trans_id != j.trans_id and 
  
  (a.trans_id not similar to ('%' || j.trans_id || '%'))
  group by stop_headsign, a.c1, j.trans_id
)
select stop_headsign, array_agg(trans_id)

from b where c1 - 1 = c2 group by stop_headsign

-- where trans_id = '稲城駅・駒沢学園・平尾団地'

-- limit 10;

-- 稲城駅・駒沢学園・平尾団地
-- 幡ヶ谷駅／永福町

