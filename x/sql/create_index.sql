-- npx wrangler d1 execute gtfsdb --remote --file="sql/create_index.sql"

create index if not exists ix_feed_feed_id on feed(feed_id);
create index if not exists ix_agency_agency_id on agency(feed_id, agency_id);
create index if not exists ix_routes_route_id on routes(feed_id, route_id);
create index if not exists ix_services_service_id on services(feed_id, service_id);
create index if not exists ix_calendar_service_id on calendar(feed_id, service_id);
create index if not exists ix_trip_patterns_pattern_id on trip_patterns(pattern_id);
create index if not exists ix_trips_trip_id on trips(feed_id, trip_id);
create index if not exists ix_stations_station_id on parent_stations(station_id);
create index if not exists ix_stops_stop_id on stops(feed_id, stop_id);
create index if not exists ix_stop_times_trip_id on stop_times(feed_id, trip_id);
create index if not exists ix_stop_patterns_stop_sequence on stop_patterns(pattern_id, stop_sequence);

create index if not exists ix_fare_attributes_fare_id on fare_attributes(feed_id, fare_id);
create index if not exists ix_fare_rules_zone_id on fare_rules(feed_id, route_id, origin_id, destination_id);
-- create index if not exists ix_translations_zone_id on translations(feed_id, fare_id, origine_id, destination_id);

create index if not exists ix_trips_pattern_id on trips(pattern_id);