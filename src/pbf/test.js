// import * as vector_tile from './pb.js';

const vector_tile = require('./pb.js');
var fs = require("fs");

async function main() {
  const response = await fetch('http://localhost:8787/api/mvts/patterns_tile/14/14539/6451/mvt.pbf');
  // const response = await fetch('https://gtfsdb.yamakyu.workers.dev/api/mvts/patterns_tile/14/14539/6451/mvt.pbf');
  // const response = await fetch('https://cyberjapandata.gsi.go.jp/xyz/experimental_bvmap/14/14567/6427.pbf');
  const arrayBuffer = await response.arrayBuffer();
  const uint8Array = new Uint8Array(arrayBuffer);
  const Tile = vector_tile.vector_tile.Tile.decode(uint8Array);
  const str = JSON.stringify(Tile, null, 2);
  fs.writeFileSync("mvt.json", str);
}

main();