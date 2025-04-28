
import jwt from 'jsonwebtoken';

export interface RequestPayload<T extends object> {
  endpointName: string;
  requestObj: T;
};

export interface ResponsePayload<T extends object> {
  status: 'ok' | 'err';
  result: T;
};

type reqType = Record<string, unknown>;

/** API共通class */
export class dbAPI<T extends reqType> {
  // private endpoint: string;
  // private requestPoint: string;
  private endpoint: string;

  getProcessor: (
    reqObj: T,
    db: D1Database
  ) => Promise<Response>;

  constructor(obj: {
    endpoint: string,
    getProcesor: (
      reqType: T,
      db: D1Database
    ) => Promise<Response>
  }) {
    this.endpoint = obj.endpoint;
    this.getProcessor = obj.getProcesor;
    return this;
  };

  get(
    request: Request,
    db: D1Database,
    apiKey: string
  ) {
    return this.auth(
      request,
      this.getProcessor,
      db,
      apiKey
    );
  };

  auth(
    req: Request,
    func: typeof this.getProcessor,
    db: D1Database,
    apiKey: string
  ) {
    if (!apiKey) return Response.json({ error: 'api key is not avilable' }, { status: 401 });

    // ヘッダ確認
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return Response.json({ error: 'without authorization header' }, { status: 401 });
  
    // JWT存在確認
    const token = authHeader.split(' ')[1];
    if (!token) return Response.json({ error: 'without token' }, { status: 401 });

    try {
      // JWTボディ部検証
      const payload = jwt.verify(token, apiKey);
      if (!isObject(payload)) return Response.json({ error: 'wrong token format' }, { status: 401 });
      if (payload.endpoint != this.endpoint) return Response.json({ error: `wrong endpoint name ${this.endpoint} ${payload.endpoint}` }, { status: 401 });
      // リクエストパラメータ検証
      const requestObj = payload.requestObj;
      if (!isObject(requestObj)) return Response.json({ error: 'wrong request parameter format' }, { status: 401 });

      return func(
        payload.requestObj as T,
        db
      ); // 型注意
    } catch (e) {
      console.log(e);
      return Response.json({ error: 'error' }, { status: 401 });
    }
  };

  
};

type queryParam = {[key: string]: string | undefined | number | object};
const isObject = (x: unknown): x is queryParam =>
  x !== null && (typeof x === 'object' || typeof x === 'function')