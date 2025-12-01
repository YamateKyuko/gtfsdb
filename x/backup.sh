#!/bin/sh
# source ./backup.sh で実行

source ./env.txt

npx wrangler d1 execute gtfsdb --remote --yes --file="sql/d1_delete.sql"
npx wrangler d1 execute gtfsdb --remote --yes --file="sql/sqlite_tables.sql"

# バックアップファイルを作成
pg_dump \
  -U $pguser \
  -d gtfsdb \
  -Fp \
  --verbose \
  --data-only \
  --schema=public \
  --column-inserts \
  --no-owner \
  --no-privileges \
  --encoding=utf8 \
  --no-acl \
  | sed -u '/^SET/d; /^SELECT pg_catalog.set_config/d' \
  | sed -u 's/INSERT INTO public\./INSERT INTO /g' \
  > "gtfsdb_backup.sql"

# ファイルが大きいと怒られるので分割
split -l 500000 gtfsdb_backup.sql ./chunks/chunk_backup_

# 分割されたファイルを順に実行
for CHUNK in ./chunks/chunk_backup_*; do
  echo "Importing $CHUNK"
  npx wrangler d1 execute gtfsdb --remote --yes --file="$CHUNK"
done

npx wrangler d1 execute gtfsdb --remote --file="sql/create_index.sql"

# 終了後、必要に応じて分割ファイルを削除
rm chunk_backup_*