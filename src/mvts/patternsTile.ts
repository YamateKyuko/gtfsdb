import { mvtsAPI } from "../mvtsAPI";

import { Buffer } from 'buffer';

const api = new mvtsAPI<{
  // z: number;
  // x: number;
  // y: number;

  tileNumber: string;
}>({
  endpoint: 'mvts/patterns_tile',

  async getProcesor(
    reqObj,
    kv: KVNamespace
  ) {
    const {
      tileNumber
    } = reqObj;

    const value = await kv.get(tileNumber) || null;

    if (!value) return Response.json({ error: 'tile not found' }, { status: 404 });

    // const file = await base64DecodeAsBlob(value);

    const str = Buffer.from(value, 'hex').toString();
    // console.log(str);

    

    const head = new Headers();
    head.set("Content-Type", "application/vnd.mapbox-vector-tile");
    head.set("access-control-allow-origin", "*");

    const res = new Response(str, {headers: head});
    // .headers("Content-Type", "application/vnd.mapbox-vector-tile");

    // if (!value)
    
    // return Response.json([]);
    
    return res;
  },
});

// async function base64DecodeAsBlob(text: string, type = "text/plain;charset=UTF-8") {
//   return fetch(`data:${type};base64,` + text).then(response => response.blob());
// }

export default api;