#!/bin/sh

# source uzip.sh CONS FEED DATE
CONS=$1
FEED=$2
DATE=$3

echo "--> GTFSDBへのインサート"

if   [ $FEED = "keiobus" ]; then
  echo "京王バス"
  URL="https://api.odpt.org/api/v4/files/odpt/KeioBus/AllLines.zip?date=${DATE}&acl:consumerKey=${CONS}"
  FEID=1
elif [ $FEED = "toeibus" ]; then
  echo "都バス"
  URL="https://api-public.odpt.org/api/v4/files/Toei/data/ToeiBus-GTFS.zip?date=${DATE}"
  FEID=2
elif [ $FEED = "seibubus" ]; then
  echo "西武バス"
  URL="https://api.odpt.org/api/v4/files/SeibuBus/data/SeibuBus-GTFS.zip?acl:consumerKey=${CONS}"
  FEID=3
elif [ $FEED = "odakyubus" ]; then
  echo "小田急バス"
  URL="https://api.odpt.org/api/v4/files/odpt/OdakyuBus/AIILines.zip?date=${DATE}&acl:consumerKey=${CONS}"
  FEID=4
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