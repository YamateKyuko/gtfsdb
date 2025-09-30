export interface Tile {
  layers?: TileLayer[];
}

export enum TileGeomType {
  UNKNOWN = 0,
  POINT = 1,
  LINESTRING = 2,
  POLYGON = 3,
}

export interface TileValue {
  stringValue?: string;
  floatValue?: number;
  doubleValue?: number;
  intValue?: number;
  uintValue?: number;
  sintValue?: number;
  boolValue?: boolean;
}

export interface TileFeature {
  id?: number;
  tags?: number[];
  type?: GeomType;
  geometry?: number[];
}

export interface TileLayer {
  name: string;
  features?: Feature[];
  keys?: string[];
  values?: Value[];
  extent?: number;
  version: number;
}

