
const fs = require('fs');
const vector_tile = require('./pb.js');

async function main() {

  
  
  let text = await fs.readFileSync("./hexmvt.txt");
  // console.log(text.toString());

  const a = await text.toString().replace('\\', '').replace('x', '');

  const st = Buffer.from(a, 'hex').toString();



  // const json = JSON.stringify(str, null, 2);

  // console.log(st);
  fs.writeFileSync("mvt.txt", st);


  const response = await fs.readFileSync("./mvt.txt");

  // console.log(response);

  // const arrayBuffer = await response.arrayBuffer();
  const uint8Array = new Uint8Array(response);
  const Tile = vector_tile.vector_tile.Tile.decode(uint8Array);
  console.log(Tile);
  const str = JSON.stringify(Tile, null, 2);
  fs.writeFileSync("mvt.json", str);
}

main();