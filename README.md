# gtfsdb

Cloudflare D1 にODPTのGTFSデータを挿入して、apiとして使うものです。
同名のプロジェクトとは一切関わっていません。私が作りました。

構成としては、
- ローカルでodptからデータを引っ張ってきて、仮テーブルに挿入。
- 本テーブルに挿入。
- 独自テーブルのデータを挿入。
- D1に挿入。
です。

コードがひどいですが、`x/sql`の独自テーブル作成用クエリなどだけでも参考にしてください。
なお、コードの一切は無保証です。動くといいね。

parent_station, trip_patterns, stop_patterns, daytype_cntなどの独自テーブルが使えます。
`x/sql/sqlite_tables.sql`などを参考にしてください。


## 使い方

gtfsdb/xのproc.shを実行してください。

なお、macOSのzshです。ほかは知らん。
また、postgresqlなどの必要パッケージ等も知らん。
gtfsdbっていうpostgresqlデータベースを作っておくこと。

.envには`DB_USER=[データベースのユーザー名]`を設定。

`source proc.sh [公共交通オープンデータセンターのAPIキー]`

ログがたくさん出てくると思うので、その中からERRORとかっていう文字を探して、なさそうだったら、
新しいworkerをつくって、gtfsdbっていう名前のデータベースをつなげて、
wrangler.jsoncに適宜書き込んでください。

`source backup.sh` を実行してください。

wranglerにログインしておくことを忘れずに。

.dev.varsには`GTFSDB_API_KEY=[システムのapiキー]`を設定。

`./apirequest.ts`を参考に、リクエスト機能を作ってください。

## ほか

雑な説明で申し訳ないです。
githubのissueとか、[ここ](https://zenn.dev/yamakyu/articles/9fa8056628e92d)とかに書いてくれたら、サポートするかも。
クライエント側とかは、[busnum](github.com/yamatekyuko/busnum)とかも参照してください。

proc.shのkeiobusは日付が必要なので、カタログサイトを見て適宜修正のこと。

