source ./env.txt

echo "--> 拡張機能のインストール"
psql -U $pguser -p 5432 -d gtfsdb -c "create extension if not exists postgis;"
psql -U $pguser -p 5432 -d gtfsdb -c "create extension if not exists pgrouting;"

echo "--> スキーマ作成"
psql gtfsdb \
  -U $pguser \
  -p 5432 \
  -v ON_ERROR_STOP=1 \
  -c "create schema if not exists map;"

echo "--> 実行"
source execsql.sh ./pgr/pgr2.sql

