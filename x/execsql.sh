#!/bin/sh

PA=$1

psql gtfsdb \
  -U $pguser \
  -p 5432 \
  -v ON_ERROR_STOP=1 \
  -q \
  -f "$PA"

if [ $? != 0 ]
then
  echo "ERROR: SQL実行失敗 ($PA)"
  return
fi