#!/bin/sh

# source uzip.sh CONS FEED DATE
CONS=$1

# 適当なシェルスクリプトに source "<conskey>" とかいてそちらを実行しましょう。(.gitignoreを忘れずに)

echo "--> GTFSDBへのインサート"

FEED=$2
DATE=$3

# 対話型も可
# echo "--> GTFSを指定:"
# read FEED
# echo "--> 日付を指定:"
# read DATE

if   [ $FEED = "keio" ]; then
  echo "京王バス"
  URL="https://api.odpt.org/api/v4/files/odpt/KeioBus/AllLines.zip?date=${DATE}&acl:consumerKey=${CONS}"
  FEID=1
elif [ $FEED = "toei" ]; then
  echo "都バス"
  URL="https://api-public.odpt.org/api/v4/files/Toei/data/ToeiBus-GTFS.zip?date=${DATE}"
  FEID=2
else
  exit
fi

echo "--> URL: $URL"

# GTFSのダウンロード
source uzip.sh $URL
# GTFSのインポート
source copy.sh $FEID
# 本テーブルへ移行
source move.sh

echo "--> GTFS挿入完了"
echo "--> 全てを挿入した後、本テーブル処理を実行してください"