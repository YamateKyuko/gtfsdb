const scriptroot = require("path").dirname(require.main.filename);


const express = require("express");
const { Pool } = require("pg");
const { format } = require("node-pg-format");
require('dotenv').config({path: `${scriptroot}/.env`});

const app = express();
const port = 3000;

// PostgreSQLデータベース接続設定
const pool = new Pool({
  user: process.env.DB_USER,
  host: "localhost",
  database: "gtfsdb",
  password: "",
  port: 5432,
});

app.get("/tiles/:z/:x/:y", async (req, res) => {
  const { z, x, y } = req.params;
  // クエリパラメータからテーブル名を取得する
  const { name } = req.query;

  // z, x, y, nameについては適宜バリデーションを入れて下さい

  // パスからバウンディングボックスが決定される
  const bbox = `st_transform(ST_TileEnvelope(${z}, ${x}, ${y}), 3857)`;

  // バウンディングボックス内のベクトルタイル生成クエリ
  const query = format(
    `SELECT ST_AsMVT(q, 'mvt_polygons'),

    array_agg(st_astext(geom)) as t
    FROM (
      SELECT
        ST_AsMVTGeom(st_transform(geom, 3857), ${bbox}),
        geom
      FROM map.test_polygons
      WHERE geom && st_transform(${bbox}, 4326)
    ) q;`
    // name
  );

  // 今回はローカル環境での試しなので、すべてのオリジンからのアクセスを許可する設定
  res.header("access-control-allow-origin", "*");

  pool.query(query, [], (error, result) => {
    if (error) {
      console.log(error);
      res.status(400).send(
        // error
        { error: "Invalid Parameters" }
      );
      return;
    }

    const tile = result.rows[0].st_asmvt;
    console.log(result.rows, [z, x, y]);

    res.header("Content-Type", "application/vnd.mapbox-vector-tile");
    res.send(tile);
  });
});

app.listen(port, () => {
  console.log(`Server is running at http://localhost:${port}`);
});


// http://localhost:3000/tiles/13/7276/3225?name=chomoku_polygons