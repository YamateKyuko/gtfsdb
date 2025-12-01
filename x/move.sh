source ./env.txt

echo "--> 本テーブルへデータ移行"
source execsql.sh ./sql/move.sql

echo "--> 翻訳データ"
source execsql.sh ./sql/translations.sql