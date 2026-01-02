with a as (

select
  t.feed_id,
  trans_id,
  lang,
  translation

from r.translations as t
left join r.stops as s on trans_id = stop_name
left join r.routes as r1 on trans_id = r1.route_short_name
left join r.stop_times as st on trans_id = stop_headsign
left join r.routes as r2 on trans_id = r2.route_long_name
where
  lang is not null and
  trans_id is not null and
  s.stop_id is null and
  r1.route_id is null and
  r2.route_id is null and
  st.stop_id is null
),
b as (
  select 
    trans_id,
    stop_headsign
  from (select trans_id from a group by trans_id)
  left join (select stop_headsign from r.stop_times group by stop_headsign)
    on stop_headsign similar to ('%' || trans_id || '%') -- 要修正
)
select * from b inner join r.translations using (trans_id)


-- where trans_id = '稲城駅・駒沢学園・平尾団地'
