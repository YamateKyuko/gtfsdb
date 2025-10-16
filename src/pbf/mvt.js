const scriptroot = process.mainModule.path;

const fs = require('fs');
const { VectorTile } = require('@mapbox/vector-tile');
const {default: Pbf} = require('pbf');
require('dotenv').config({path: `${scriptroot}/.env`});
const { Client } = require('pg');

async function main() {

  // import { Client } from 'pg'
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: process.env.UN,
    password: '',
    database: 'gtfsdb'
  });
  await client.connect();
  const res = await client.query(`
with points as (
  select
    --     SELECT ST_SetSRID(ST_MakePoint(135, 35), 4326);st_transform(geom, 3857) as 
    geom,
    name
  from (values
    (st_transform(st_geomfromgeojson('{"type":"Point","coordinates":[139.7453357780371,35.65865995892796]}'::text), 4326), 'nishiwaki')
    -- (st_transform(st_geomfromgeojson('{"type":"Point","coordinates":[135,35]}'::text), 4326), 'nishiwaki')
    -- (ST_SetSRID(ST_MakePoint(135, 35), 4326),'nishiwaki')
  ) as t(geom,name)
),
mvts as (
  select
  st_asmvt(
    t,
    'poly',
    4096,
    'geom'
  ) as mvt,
	array_agg(st_srid(geom)),
	array_agg(st_astext(st_transform(geom, 4326)))
  from (
    select
      st_asmvtgeom(
        st_transform(geom, 3857),
        st_transform(st_tileenvelope(1,1,0), 3857),
				4096,
				256
      ) as geom,
      -- 'hoge' as 
      name,
      st_srid(geom) as srid
    from points
    where geom && st_transform(st_tileenvelope(1,1,0), 4326)
  ) as t
)
select btrim(mvt::TEXT, '\\x') as mvt from mvts;
  `);
  console.log(res.rows);

  

  await client.end();

  const datum = res.rows[0].mvt;

  const buffer = Buffer.from(datum, 'hex');

  
  // let text = await fs.readFileSync(`${scriptroot}/hexmvt.txt`);

  // const a = await text.toString().replace('\\', '').replace('x', '');

  // const st = Buffer.from(a, 'hex').toString();

  // fs.writeFileSync(`${scriptroot}/mvt.txt`, st);


  // console.log(Pbf)
  

  // hex文字列を取得
  // const response = fs.readFileSync(`${scriptroot}/hexmvt.txt`, 'utf8');

  // hex文字列→バイナリ変換
  
  // const buffer = Buffer.from(response.trim(), 'hex');

  // var buffer = toArrayBuffer(response);




  // const response = await fetch('https://cyberjapandata.gsi.go.jp/xyz/experimental_bvmap/14/14567/6427.pbf');
  // const buffer = await response.arrayBuffer();


  // console.log(buffer);


  // デコード
  const pbf = new Pbf(buffer);
  const tile = new VectorTile(pbf);
  
  // console.log(tile.layers);

  // レイヤーごとにGeoJSON化
  for (const layerName in tile.layers) {

    console.log("layerName:", layerName);
    const layer = tile.layers[layerName];
    const features = [];
    for (let i = 0; i < layer.length; i++) {
      features.push(layer.feature(i).toGeoJSON(0, 0, 0));
    }
    // console.log(features);
    fs.writeFileSync(`${scriptroot}/${layerName}.json`, JSON.stringify(features, null, 2));
  }
}

main();






function toArrayBuffer(buffer) {
    var ab = new ArrayBuffer(buffer.length);
    var view = new Uint8Array(ab);
    for (var i = 0; i < buffer.length; ++i) {
        view[i] = buffer[i];
    }
    return ab;
}