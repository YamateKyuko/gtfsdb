drop index if exists ix_feed_feed_id;
drop index if exists ix_agency_agency_id;
drop index if exists ix_routes_route_id;
drop index if exists ix_services_service_id;
drop index if exists ix_calendar_service_id;
drop index if exists ix_trip_patterns_pattern_id;
drop index if exists ix_trips_trip_id;
drop index if exists ix_stations_station_id;
drop index if exists ix_stops_stop_id;
drop index if exists ix_stop_times_trip_id;
drop index if exists ix_stop_patterns_stop_sequence;

drop index if exists ix_stop_times_arrival_time;
drop index if exists ix_stop_times_departure_time;

drop index if exists ix_fare_attributes_fare_id;
drop index if exists ix_fare_rules_zone_id;

delete from translations;
delete from fare_rules;
delete from fare_attributes;

delete from stop_patterns;
delete from trip_patterns;
delete from parent_stations;
delete from stop_times;
delete from stops;
delete from trips;
delete from calendar;
delete from services;
delete from routes;
delete from agency;
delete from feed;