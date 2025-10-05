const fs = require('fs');
const { VectorTile } = require('@mapbox/vector-tile');
const Pbf = require('pbf');

// hex文字列を取得
const hex = fs.readFileSync('tile.hex', 'utf8'); // 例: ファイルから取得
const uint8Array = hexToUint8Array(hex);

// デコード
const tile = new VectorTile(new Pbf(uint8Array));

// レイヤーごとにGeoJSON化
for (const layerName in tile.layers) {
  const layer = tile.layers[layerName];
  const features = [];
  for (let i = 0; i < layer.length; i++) {
    features.push(layer.feature(i).toGeoJSON(0, 0, 0));
  }
  fs.writeFileSync(`${layerName}.json`, JSON.stringify(features, null, 2));
}