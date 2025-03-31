import stopPatternsAPI from "./gtfsdb/stopPatterns";
import stopTimesAPI from "./gtfsdb/stopTimes";

export interface Env {
  DB: D1Database;
  GTFSDB_API_KEY?: string;
}

export default {
  async fetch(req, env): Promise<Response> {
    const apiKey = env.GTFSDB_API_KEY || '';
    const { pathname } = new URL(req.url);
    const paths = pathname.split('/');

    if (!(paths[1] == 'api')) return Response.json({gtfsdb: 'Not Found'}, { status: 404 })

    switch (paths[2]) {
      case 'gtfsdb':
        switch (paths[3]) {
          case 'stop_patterns':
            return await stopPatternsAPI.get(req, env.DB, apiKey);
          case 'stop_times':
            return await stopTimesAPI.get(req, env.DB, apiKey);
          default:
            return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
        };
      default:
        return Response.json({gtfsdb: 'Not Found'}, { status: 404 })
    }
  },
} satisfies ExportedHandler<Env>;