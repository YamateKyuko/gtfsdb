import { mvtsAPI } from "../mvtsAPI";

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

    const value = await kv.get(tileNumber) || '';

    const file = await base64DecodeAsBlob(value);

    console.log(file);

    
    // if (!value) return 

    const head = new Headers();
    head.set("Content-Type", "application/vnd.mapbox-vector-tile");

    const res = new Response(value, {headers: head});
    // .headers("Content-Type", "application/vnd.mapbox-vector-tile");

    // if (!value)
    
    // if (!results) return Response.json([]);
    
    return Response.json({})
  },
});

async function base64DecodeAsBlob(text: string, type = "text/plain;charset=UTF-8") {
  return fetch(`data:${type};base64,` + text).then(response => response.blob());
} 

export default api;