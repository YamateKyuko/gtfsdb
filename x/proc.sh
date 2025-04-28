#!/bin/sh

echo "--> 処理テーブル設定"
psql gtfsdb \
  -U akaki \
  -p 5432 \
  -f ./sql/postgres_tables.sql

source inst.sh "$1" "keiobus" "20250401"
source inst.sh "" "toeibus" ""
source inst.sh "$1" "seibubus" ""

# echo "--> 仮テーブル削除"
# psql gtfsdb \
#   -U akaki \
#   -p 5432 \
#   -c "drop schema if exists r cascade;"

# echo "--> パターン設定"
# psql gtfsdb \
#   -U akaki \
#   -p 5432 \
#   -f ./sql/ptn.sql

# echo "--> duration_time設定"
# psql gtfsdb \
#   -U akaki \
#   -p 5432 \
#   -f ./sql/duration_time.sql

# echo "--> stop_offsets付加"
# psql gtfsdb \
#   -U akaki \
#   -p 5432 \
#   -f ./sql/stop_offsets.sql

# echo "--> parent_stations挿入"
# psql gtfsdb \
#   -U akaki \
#   -p 5432 \
#   -f ./sql/parent_stations.sql

# echo "--> GTFSDBへのインサート"
# source backup.sh