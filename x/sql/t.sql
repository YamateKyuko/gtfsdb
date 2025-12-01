-- select * from translations limit 100;
-- drop table translations cascade;

-- select * from translations 
-- where 
-- feed_id = 1 and
-- field_name='stop_headsign'
-- limit 100;



-- 京王バス
-- stops stop_name field_value
-- stop_times stop_headsign record_id record_sub_id
-- routes route_short_name record_id record_sub_id
-- agency agency_name field_value
-- feed_info feed_publisher_name 

-- 都バス
-- stops stop_name record_id
-- stop_times stop_headsign field_value
-- trips trip_headsign field_value

-- 西武バス
-- stops stop_name record_id
-- stop_times stop_headsign field_value
-- trips trip_headsign field_value

-- 'stop_name', 'stop_headsign', 'route_short_name', 'agency_name', 'feed_publisher_name'