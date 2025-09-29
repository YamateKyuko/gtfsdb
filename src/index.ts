import stopPatternsAPI from "./gtfsdb/stopPatterns";
import stopTimesAPI from "./gtfsdb/stopTimes";
import diaTimesAPI from "./gtfsdb/diaTimes";

import patternsTileAPI from "./mvts/patternsTile";

import apiTest from "./apiTest";

export interface Env {
  GTFSDB: D1Database;
  MVTS: KVNamespace;
  GTFSDB_API_KEY?: string;
  TEST_API_KEY?: string;
}

export default {
  async fetch(req, env): Promise<Response> {
    const apiKey = env.GTFSDB_API_KEY || null;
    const testapikey = env.TEST_API_KEY || null;
    const { pathname } = new URL(req.url);
    const paths = pathname.split('/');

    if (!apiKey || !testapikey) return Response.json({gtfsdb: 'Key not Found'}, { status: 404 })

    // パス仕分け
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
          default:
            return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
        };
      case 'mvts':
        switch (paths[3]) {
          case 'patterns_tile':
            return await patternsTileAPI.get(req, env.MVTS);
          default:
            return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
        };
      case 'test':
        return await apiTest(req, testapikey, apiKey);
      default:
        return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
    }
  },
} satisfies ExportedHandler<Env>;



