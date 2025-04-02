#!/bin/sh

FEID=$1

DRCT=$(cd $(dirname $0); pwd)

ARRY=(
  "feed_info"
  "agency"
  "agency_jp"
  "routes"
  "calendar"
  "calendar_dates"
  "trips"
  "stops"
  "stop_times"
)

# COLS=(
#   "feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version"
#   "agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email"
#   "agency_id,agency_official_name,agency_zip_number,agency_address,agency_president_pos,agency_president_name"
#   "route_id,agency_id,route_short_name,route_long_name,route_desc,route_type,route_url,route_color,route_text_color,jp_parent_route_id"
#   "service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date"
#   "service_id,date,exception_type"
#   "route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id,wheelchair_accessible,bikes_allowed,jp_trip_desc,jp_trip_desc_symbol,jp_office_id"
#   "stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station,stop_timezone,wheelchair_boarding,platform_code"
#   "trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint"
# )

echo "--> 仮テーブル設定"

psql gtfsdb \
  -U akaki \
  -p 5432 \
  -f ./sql/raw_tables.sql

echo "--> CSVからコピー"
for IDX in `seq 1 9`
do
  if [ -e "${DRCT}/unzipped/${ARRY[$IDX]}.txt" ]; then
    echo "--> ${ARRY[$IDX]}.txtの処理"
    CLMN=`head -n 1 ${DRCT}/unzipped/${ARRY[$IDX]}.txt`
    psql gtfsdb \
      -U akaki \
      -p 5432 \
      -c "copy r.${ARRY[$IDX]}(${CLMN}) from '${DRCT}/unzipped/${ARRY[$IDX]}.txt' with (format csv, delimiter ',', header match);"
  else
    echo "--> ${ARRY[$IDX]}.txtは存在しません"
  fi
done

# COPY r.agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone,agency_fare_url,agency_email)
# 	FROM '/Users/akaki/Desktop/desktop/ODPT/cloudflare/gtfsdb/x/unzipped/agency.txt'
# 	with (
# 		format CSV,
# 		delimiter ',',
# 		header match
# 	);

echo "--> feed_idの付加"
psql gtfsdb \
  -U akaki \
  -p 5432 \
  -c "select r.feed_ider($FEID);"