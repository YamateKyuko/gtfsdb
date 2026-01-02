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
  --rows-per-insert=100 \
  | sed -u '/^SET/d; /^SELECT pg_catalog.set_config/d' \
  | sed -u 's/INSERT INTO public\./INSERT INTO /g' \
  > "gtfsdb_backup.sql"

# rows-per-insert=nrows

# ファイルが大きいと怒られるので分割
awk '
BEGIN {
  file_num = 0;
  lines = 0;
  limit = 100000; # 分割の目安となる行数 (これを超えたら次のセミコロンで切る)
  out_prefix = "./chunks/chunk_backup_";
}
{
  # ファイル名決定 (連番: 000, 001, ...)
  if (lines == 0) {
    out = sprintf("%s%03d", out_prefix, file_num);
  }
  print $0 > out;
  lines++;
  
  # セミコロンで終わる行 かつ 閾値を超えていたらファイルを閉じて次へ
  if ($0 ~ /;[[:space:]]*$/ && lines > limit) {
    close(out);
    file_num++;
    lines = 0;
  }
}
' gtfsdb_backup.sql

# 分割されたファイルを順に実行
for CHUNK in ./chunks/chunk_backup_*; do
  echo "Importing $CHUNK"
  npx wrangler d1 execute gtfsdb --remote --yes --file="$CHUNK"
done

npx wrangler d1 execute gtfsdb --remote --file="sql/create_index.sql"

# 終了後、必要に応じて分割ファイルを削除
rm chunk_backup_*