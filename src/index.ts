import stopPatternsAPI from "./gtfsdb/stopPatterns";
import stopTimesAPI from "./gtfsdb/stopTimes";
import diaTimesAPI from "./gtfsdb/diaTimes";
import stationsAPI from "./gtfsdb/stations";
import stationTimesAPI from "./gtfsdb/stationTimes";
import patternTimesAPI from "./gtfsdb/patternTimes";

// import patternsTileAPI from "./mvts/patternsTile";

// import apiTest from "./apiTest";

export interface Env {
  GTFSDB: D1Database;
  mvts: KVNamespace;
  GTFSDB_API_KEY?: string;
  TEST_API_KEY?: string;
  // ASSETS: assets;
}

export default {
  async fetch(req, env): Promise<Response> {
    const apiKey = env.GTFSDB_API_KEY || null;
    // const testapikey = env.TEST_API_KEY || null;
    const { pathname } = new URL(req.url);
    const paths = pathname.split('/');

    if (!apiKey) return Response.json({gtfsdb: 'Key not Found'}, { status: 404 })

    // パス仕分け
    // const html = '<div>hello</div>'
    // if (paths[1] == 'info') return new Response(html, { status: 200, headers: { 'Content-Type': 'text/html' } });
    if (!(paths[1] == 'api')) return Response.json({gtfsdb: 'Not Found'}, { status: 404 })

    switch (paths[2]) {
      case 'gtfsdb':
        switch (paths[3]) {
          case 'stop_patterns':
            return await stopPatternsAPI.get(req, env.GTFSDB, apiKey);
          case 'stop_times':
            return await stopTimesAPI.get(req, env.GTFSDB, apiKey);
          case 'dia_times':
            return await diaTimesAPI.get(req, env.GTFSDB, apiKey);
          case 'stations':
            return await stationsAPI.get(req, env.GTFSDB, apiKey);
          case 'station_times':
            return await stationTimesAPI.get(req, env.GTFSDB, apiKey);
          case 'pattern_times':
            return await patternTimesAPI.get(req, env.GTFSDB, apiKey);
          default:
            return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
        };
      // case 'mvts':
      //   switch (paths[3]) {
      //     case 'patterns_tile':
      //       return await patternsTileAPI.get(req, env.mvts);
      //     default:
      //       return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
      //   };
      // case 'test':
        // return await apiTest(req, testapikey, apiKey);
      default:
        return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
    }
  },
} satisfies ExportedHandler<Env>;