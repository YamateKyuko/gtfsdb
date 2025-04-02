#!/bin/sh

# source uzip.sh URL

ZIP_URL=$1

ZIP_FILE="downloaded.zip"

echo "--> GTFSのダウンロード"

curl -L -o "$ZIP_FILE" "$ZIP_URL"

echo "--> GTFSの解凍"

UNZIP_DIR="unzipped"
rm -r "$UNZIP_DIR"
mkdir -p "$UNZIP_DIR"

# 解凍
unzip -o "$ZIP_FILE" -d "$UNZIP_DIR"