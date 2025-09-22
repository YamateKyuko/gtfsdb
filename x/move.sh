source ./env.txt

echo "--> 本テーブルへデータ移行"
psql gtfsdb \
  -U $pguser \
  -p 5432 \
  -f ./sql/move.sql