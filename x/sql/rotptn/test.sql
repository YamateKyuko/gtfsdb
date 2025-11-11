-- with ptns as (
--   select stop_patterns.*, station_id
--   from stop_patterns inner join stops using (feed_id, stop_id) where route_name = '武７３'
-- ),
-- a as (
-- select 
--   ptn1.feed_id,
--   ptn1.route_id,
--   ptn1.pattern_id,
--   ptn1.stop_name as spn,
--   ptn1.station_id as sp,
--   ptn2.stop_name as snn,
--   ptn2.station_id as sn,
--   ptn1.stop_sequence,
--   ptn1.direction_id
--   -- row_number() over(group by )
-- from ptns ptn1
-- inner join ptns as ptn2 on
--   ptn1.pattern_id = ptn2.pattern_id and (
--     (ptn1.direction_id = 0 and (ptn1.stop_sequence + 1) = ptn2.stop_sequence) or
--     (ptn1.direction_id = 1 and (ptn2.stop_sequence + 1) = ptn1.stop_sequence))

-- 
-- order by pattern_id, ptn1.stop_sequence
-- ),
-- b as (
--   select 
--     feed_id,
--     route_id,
--     sp,
--     sn,
--     array_agg(pattern_id order by pattern_id) as ptns,
--     array_agg(stop_sequence order by pattern_id)
--   from a
--   group by feed_id, route_id, sp, sn
-- )
-- -- c as (
-- --   select * from b
-- -- )

-- select * from b;






with ptns as (
  select
    stop_patterns.*,
    station_id,
    (select case direction_id
      when 0 then stop_sequence
      when 1 then stop_sequence * -1
      -- (last_value(stop_sequence) over(partition by pattern_id order by stop_sequence)) - stop_sequence + 1
    end) as rsq
  from stop_patterns inner join stops using (feed_id, stop_id) where route_name = '武７３'
),
a as (
  select distinct on (feed_id, route_id) feed_id, route_id, stop_id as bst from ptns
),
b as (
  select 
    ptns.*,
    a.bst,
    (ptns.stop_sequence - pb.stop_sequence) as bdst


  from ptns
  inner join a using(feed_id, route_id)
  inner join ptns as pb on ptns.pattern_id = pb.pattern_id and pb.stop_id = a.bst
  order by pattern_id, rsq
)
select * from b order by bdst;