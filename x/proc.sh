#!/bin/sh

source ./env.txt

# dropdb -U $pguser -p 5432 -f gtfsdb
# createdb gtfsdb

# psql gtfsdb -U $pguser -p 5432 -c "set client_min_messages to error;"

echo "--> 処理テーブル設定"
source execsql.sh ./sql/raw_tables.sql
source execsql.sh ./sql/postgres_tables.sql

# psql gtfsdb -U $pguser -p 5432 -c "set client_min_messages to notice;"

source inst.sh "$1" "keiobus" "20251117"
source inst.sh "" "toeibus" ""
source inst.sh "$1" "seibubus" ""



echo "--> 仮テーブル削除"
psql gtfsdb \
  -U $pguser \
  -p 5432 \
  -v ON_ERROR_STOP=1 \
  -c "drop schema if exists r cascade;"

echo "--> パターン設定"
source execsql.sh ./sql/ptn.sql

echo "--> duration_time設定"
source execsql.sh ./sql/duration_time.sql

echo "--> 本数挿入"
source execsql.sh ./sql/daycnt/day.sql

echo "--> parent_stations挿入"
source execsql.sh ./sql/parent_stations.sql

echo "--> 休日挿入"
source execsql.sh ./sql/daycnt/h.sql

# echo "--> GTFSDBへのインサート"
# source backup.sh