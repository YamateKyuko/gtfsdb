echo "--> 本テーブルへデータ移行"
psql gtfsdb \
  -U akaki \
  -p 5432 \
  -f ./sql/move.sql

echo "--> 仮テーブル削除"
psql gtfsdb \
  -U akaki \
  -p 5432 \
  -c "drop schema if exists r cascade;"