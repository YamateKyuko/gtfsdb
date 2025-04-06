echo "--> 本テーブルへデータ移行"
psql gtfsdb \
  -U akaki \
  -p 5432 \
  -f ./sql/move.sql