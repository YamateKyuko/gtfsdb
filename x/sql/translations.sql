create table stop_name_translations (
  feed_id smallint not null,
  stop_id varchar(63) not null,
  language varchar(7) not null,
  translation varchar(255),
  field_value varchar(255)
);

select 
  translations.feed_id,
  stop_id,
  language,
  translation,
  field_value
from r.translations 
inner join stops on (
  stops.feed_id = translations.feed_id and
  stop_name = field_value
)
where
  table_name = 'stops' and
  field_name = 'stop_name' and
  record_id is null and
  record_sub_id is null and
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
  field_value is null
limit 100;

select
  translations.feed_id,
  trip_id,
  stop_sequence,
  language,
  translation,
  field_value
from r.translations
inner join stop_times on (
  stop_times.feed_id = translations.feed_id and
  stop_times.stop_headsign = translations.field_value
)
where
  table_name = 'stop_times' and
  field_name = 'stop_headsign' and
  record_id is null and
  record_sub_id is null and
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
  record_sub_id is not null
limit 100;

select
  translations.feed_id,
  route_id,
  language,
  translation,
  field_value
from r.translations
inner join routes on (
  routes.feed_id = translations.feed_id and
  routes.route_short_name = translations.field_value
)
where
  table_name = 'routes' and
  field_name = 'route_short_name' and
  record_id is null and
  record_sub_id is null and
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
  field_value is null
limit 100;

select
  translations.feed_id,
  trip_id,
  language,
  translation,
  field_value
from r.translations
inner join trips on (
  trips.feed_id = translations.feed_id and
  trips.trip_headsign = translations.field_value
)
where
  table_name = 'trips' and
  field_name = 'trip_headsign' and
  record_id is null and
  record_sub_id is null and
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
  field_value is null
limit 100;

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