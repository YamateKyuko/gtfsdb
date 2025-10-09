const fs = require('fs');
const { VectorTile } = require('@mapbox/vector-tile');
const {default: Pbf} = require('pbf'); // ← ここを修正

async function main() {
  const scriptroot = process.mainModule.path;
  let text = await fs.readFileSync(`${scriptroot}/hexmvt.txt`);

  const a = await text.toString().replace('\\', '').replace('x', '');

  const st = Buffer.from(a, 'hex').toString();

  fs.writeFileSync(`${scriptroot}/mvt.txt`, st);


  // console.log(Pbf)
  

  // hex文字列を取得
  const response = fs.readFileSync(`${scriptroot}/hexmvt.txt`, 'utf8');

  // hex文字列→バイナリ変換
  
  const buffer = Buffer.from(response.trim(), 'hex');

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