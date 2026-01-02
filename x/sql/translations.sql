insert into stop_name_translations
select 
  translations.feed_id,
  null as stop_id,
  language,
  translation,
  field_value
from r.translations 
where
  table_name = 'stops' and
  field_name = 'stop_name' and
  record_id is null and
  record_sub_id is null and
  field_value is not null and
  language is not null and
  field_value is not null
union
select 
  feed_id,
  record_id as stop_id,
  language,
  translation,
  field_value
from r.translations 
where
  table_name = 'stops' and
  field_name = 'stop_name' and
  record_id is not null and
  record_sub_id is null and
  field_value is null and
  language is not null and
  field_value is not null;

insert into stop_headsign_translations
select
  translations.feed_id,
  null as trip_id,
  null as stop_sequence,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'stop_times' and
  field_name = 'stop_headsign' and
  record_id is null and
  record_sub_id is null and
  field_value is not null and
  language is not null and
  field_value is not null
union
select
  translations.feed_id,
  record_id as trip_id,
  record_sub_id::integer as stop_sequence,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'stop_times' and
  field_name = 'stop_headsign' and
  record_id is not null and
  record_sub_id is not null and
  language is not null and
  field_value is not null;

insert into route_short_name_translations
select
  translations.feed_id,
  null as route_id,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'routes' and
  field_name = 'route_short_name' and
  record_id is null and
  record_sub_id is null and
  field_value is not null and
  language is not null and
  field_value is not null
union
select
  translations.feed_id,
  record_id as route_id,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'routes' and
  field_name = 'route_short_name' and
  record_id is not null and
  record_sub_id is null and
  field_value is null and
  language is not null and
  field_value is not null;

insert into trip_headsign_translations
select
  translations.feed_id,
  null as trip_id,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'trips' and
  field_name = 'trip_headsign' and
  record_id is null and
  record_sub_id is null and
  field_value is not null and
  language is not null and
  field_value is not null
union
select
  translations.feed_id,
  record_id as trip_id,
  language,
  translation,
  field_value
from r.translations
where
  table_name = 'trips' and
  field_name = 'trip_headsign' and
  record_id is not null and
  record_sub_id is null and
  field_value is null and
  language is not null and
  field_value is not null;

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

