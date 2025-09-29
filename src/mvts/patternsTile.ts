import { mvtsAPI } from "../mvtsAPI";

const api = new mvtsAPI<{
  // z: number;
  // x: number;
  // y: number;
}>({
  endpoint: 'mvts/patternsTile',

  async getProcesor(
    reqObj,
    kv: KVNamespace
  ) {
    // const {
    //   feed_id: feedId,
    //   trip_id: tripId
    // } = reqObj;

    // console.log(reqObj);

    // const value = await kv.get("user_2");
    
    // if (!results) return Response.json([]);
    
    return Response.json({v: "aaa"});
  },
});

export default api;