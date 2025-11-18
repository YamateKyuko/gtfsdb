
import jwt from 'jsonwebtoken';

export interface RequestPayload<T extends object> {
  endpointName: string;
  requestObj: T;
};

export interface ResponsePayload<T extends object> {
  status: 'ok' | 'err';
  result: T;
};

// reqType: tsの型

// enty: 実体の型
// type reqType = Record<string, reqTypeVs>;
// type reqTypeVs = string | number | boolean;
// type reqTypeVToEntyV<T extends reqTypeVs> =
//   T extends string ? 'string':
//   T extends number ? 'number':
//   T extends boolean ? 'boolean':
//   never;
// type reqTypeToEnty<T extends reqType> = Readonly<{[newK in keyof T]: reqTypeVToEntyV<T[newK]>}>;
// type Enty<T extends reqType> = reqTypeToEnty<T>;

type Enty = Readonly<Record<string, EntyVs>>;
type EntyVs = 'string' | 'number' | 'boolean' | 'string[]' | 'number[]' | 'boolean[]' | 'number | null';
type EntyVToReqTypeV<T extends EntyVs> = 
  T extends 'string' ? string :
  T extends 'number' ? number :
  T extends 'boolean' ? boolean :
  T extends 'string[]' ? string[] :
  T extends 'number[]' ? number[] :
  T extends 'boolean[]' ? boolean[] :
  T extends 'number | null' ? number | null :
  never;
type EntyToReqType<T extends Enty> = {[newK in keyof T]: EntyVToReqTypeV<T[newK]>};
type reqType<T extends Enty> = EntyToReqType<T>;

/** API共通class */
export class dbAPI<T extends Enty> {
  // private endpoint: string;
  // private requestPoint: string;
  private endpoint: string;
  readonly enty: T;

  getProcessor: (
    reqObj: reqType<T>,
    db: D1Database
  ) => Promise<Response>;

  constructor(obj: {
    endpoint: string,
    readonly enty: T,
    getProcesor: (
      reqType: reqType<T>,
      db: D1Database
    ) => Promise<Response>
  }) {
    this.endpoint = obj.endpoint;
    this.enty = obj.enty;
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
    if (!authHeader) {
      const url = new URL(req.url);
      const requestParams = new URLSearchParams(url.search);
      const token = requestParams.get('token');
      if (!token) return Response.json({ error: 'without authorization header' }, { status: 401 });
      if (typeof token !== 'string') return Response.json({ error: 'wrong token format' }, { status: 401 });
      if (token !== apiKey) return Response.json({ error: 'wrong token' }, { status: 401 });
      const entyKeys = Object.keys(this.enty);
      const requestObj: Record<string, unknown> = {};
      for (const k of entyKeys) {
        const rv = requestParams.get(k);
        const entyV = this.enty[k];
        switch (entyV) {
          case 'string':
            if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
            requestObj[k] = rv;
            break;
          case 'number':
            if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
            const nv = Number(rv);
            if (isNaN(nv)) return Response.json({ error: `wrong parameter format ${k}` }, { status: 401 });
            requestObj[k] = nv;
            break;
          case 'boolean':
            if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
            if (rv !== 'true' && rv !== 'false') return Response.json({ error: `wrong parameter format ${k}` }, { status: 401 });
            requestObj[k] = rv === 'true' ? true : false;
            break;
          case 'string[]':
            {
              if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
              const arr = rv.split(',');
              requestObj[k] = arr;
            }
            break;
          case 'number[]':
            {
              if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
              const arr = rv.split(',').map(v => {
                const nv = Number(v);
                if (isNaN(nv)) return null;
                return nv;
              });
              if (arr.includes(null)) return Response.json({ error: `wrong parameter format ${k}` }, { status: 401 });
              requestObj[k] = arr as number[];
            }
            break;
          case 'boolean[]':
            {
              if (rv === null) return Response.json({ error: `missing parameter ${k}` }, { status: 401 });
              const arr = rv.split(',').map(v => {
                if (v !== 'true' && v !== 'false') return null;
                return v === 'true' ? true : false;
              });
              if (arr.includes(null)) return Response.json({ error: `wrong parameter format ${k}` }, { status: 401 });
              requestObj[k] = arr as boolean[];
            }
            break;
          default:
            return Response.json({ error: `wrong enty type ${k}` }, { status: 401 });
        }
      }

    };

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
        payload.requestObj as reqType<T>,
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