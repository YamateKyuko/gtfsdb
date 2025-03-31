import * as jwt from 'jsonwebtoken'

export function authenticate(
  req: Request,
  func: (path: string, val: queryParam) => Promise<Response>,
  apiKey: string
) {
  const authHeader = req.headers.get('Authorization');

  if (!authHeader) {
    return Response.json({ error: 'without authorization header' }, { status: 401 });
  }

  const token = authHeader.split(' ')[1];

  if (!token) {
    return Response.json({ error: 'without token' }, { status: 401 });
  }

  if (!apiKey) {
    return Response.json({ error: 'without api key' }, { status: 401 });
  }

  try {
    const decoded = jwt.verify(token, apiKey);
    if (isObject(decoded)) {
      const { pathname } = new URL(req.url);
      return func(pathname, decoded);
    }
    return Response.json({ error: 'wrong key' }, { status: 401 });
  } catch (e) {
    console.log(e);
    return Response.json({ error: 'error' }, { status: 401 });
  }
};

export type queryParam = {[key: string]: string | undefined | number};
const isObject = (x: unknown): x is queryParam =>
  x !== null && (typeof x === 'object' || typeof x === 'function')
