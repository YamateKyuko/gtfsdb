
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
export class mvtsAPI<T extends reqType> {
  // private endpoint: string;
  // private requestPoint: string;
  private endpoint: string;

  getProcessor: (
    reqObj: T,
    kv: KVNamespace
  ) => Promise<Response>;

  constructor(obj: {
    endpoint: string,
    getProcesor: (
      reqType: T,
      kv: KVNamespace
    ) => Promise<Response>
  }) {
    this.endpoint = obj.endpoint;
    this.getProcessor = obj.getProcesor;
    return this;
  };

  get(
    request: Request,
    kv: KVNamespace
    // apiKey: string
  ) {
    return this.auth(
      request,
      this.getProcessor,
      kv
      // apiKey
    );
  };

  auth(
    req: Request,
    func: typeof this.getProcessor,
    kv: KVNamespace
    // apiKey: string
  ) {

    
    // if (!apiKey) return Response.json({ error: 'api key is not avilable' }, { status: 401 });

  //   // ヘッダ確認
  //   const authHeader = req.headers.get('Authorization');
  //   if (!authHeader) return Response.json({ error: 'without authorization header' }, { status: 401 });
  
  //   // JWT存在確認
  //   const token = authHeader.split(' ')[1];
  //   if (!token) return Response.json({ error: 'without token' }, { status: 401 });

    try {
      // JWTボディ部検証
      // const payload = jwt.verify(token, apiKey);
      // if (!isObject(payload)) return Response.json({ error: 'wrong token format' }, { status: 401 });
      // if (payload.endpoint != this.endpoint) return Response.json({ error: `wrong endpoint name ${this.endpoint} ${payload.endpoint}` }, { status: 401 });
      // リクエストパラメータ検証
      // const requestObj = payload.requestObj;
      // if (!isObject(requestObj)) return Response.json({ error: 'wrong request parameter format' }, { status: 401 });

      // return func(
      //   payload.requestObj as T,
      //   kv
      // ); // 型注意

      const { pathname } = new URL(req.url);
      const paths = pathname.split('/');
      
      const z = Number(paths[4]);
      const x = Number(paths[5]);
      const y = Number(paths[6]);
      const filename = paths[7] || null;

      if (filename != 'mvt.pbf') return Response.json({ error: 'wrong file name' }, { status: 400 });

      if (!x || !y || !z) return Response.json({ error: 'wrong tile number' }, { status: 400 });

      const obj = {
        tileNumber: `${z}/${x}/${y}`
      };

      console.log(req);


      return func(
        obj as unknown as T,
        kv
      ); // 型注意
    } catch (e) {
      console.log(e);
      return Response.json({ error: 'error' }, { status: 401 });
    }
  };

  
};

type queryParam = {[key: string]: string | undefined | number | object};
const isObject = (x: unknown): x is queryParam =>
  x !== null && (typeof x === 'object' || typeof x === 'function');