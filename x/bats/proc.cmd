@echo off

echo "--> 処理テーブル設定"
@REM psql gtfsdb \
@REM   -U akaki \
@REM   -p 5432 \
@REM   -f ./sql/postgres_tables.sql

@REM source inst.sh "$1" "keiobus" "20250401"
@REM source inst.sh "" "toeibus" ""
@REM source inst.sh "$1" "seibubus" ""

@REM # echo "--> 仮テーブル削除"
@REM # psql gtfsdb \
@REM #   -U akaki \
@REM #   -p 5432 \
@REM #   -c "drop schema if exists r cascade;"

@REM # echo "--> パターン設定"
@REM # psql gtfsdb \
@REM #   -U akaki \
@REM #   -p 5432 \
@REM #   -f ./sql/ptn.sql

@REM # echo "--> duration_time設定"
@REM # psql gtfsdb \
@REM #   -U akaki \
@REM #   -p 5432 \
@REM #   -f ./sql/duration_time.sql

@REM # echo "--> stop_offsets付加"
@REM # psql gtfsdb \
@REM #   -U akaki \
@REM #   -p 5432 \
@REM #   -f ./sql/stop_offsets.sql

@REM # echo "--> parent_stations挿入"
@REM # psql gtfsdb \
@REM #   -U akaki \
@REM #   -p 5432 \
@REM #   -f ./sql/parent_stations.sql

@REM # echo "--> GTFSDBへのインサート"
@REM # source backup.sh