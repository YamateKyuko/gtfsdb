/*eslint-disable block-scoped-var, id-length, no-control-regex, no-magic-numbers, no-prototype-builtins, no-redeclare, no-shadow, no-var, sort-vars*/
"use strict";

var $protobuf = require("protobufjs/minimal");

// Common aliases
var $Reader = $protobuf.Reader, $Writer = $protobuf.Writer, $util = $protobuf.util;

// Exported root namespace
var $root = $protobuf.roots["default"] || ($protobuf.roots["default"] = {});

$root.vector_tile = (function() {

    /**
     * Namespace vector_tile.
     * @exports vector_tile
     * @namespace
     */
    var vector_tile = {};

    vector_tile.Tile = (function() {

        /**
         * Properties of a Tile.
         * @memberof vector_tile
         * @interface ITile
         * @property {Array.<vector_tile.Tile.ILayer>|null} [layers] Tile layers
         */

        /**
         * Constructs a new Tile.
         * @memberof vector_tile
         * @classdesc Represents a Tile.
         * @implements ITile
         * @constructor
         * @param {vector_tile.ITile=} [properties] Properties to set
         */
        function Tile(properties) {
            this.layers = [];
            if (properties)
                for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                    if (properties[keys[i]] != null)
                        this[keys[i]] = properties[keys[i]];
        }

        /**
         * Tile layers.
         * @member {Array.<vector_tile.Tile.ILayer>} layers
         * @memberof vector_tile.Tile
         * @instance
         */
        Tile.prototype.layers = $util.emptyArray;

        /**
         * Creates a new Tile instance using the specified properties.
         * @function create
         * @memberof vector_tile.Tile
         * @static
         * @param {vector_tile.ITile=} [properties] Properties to set
         * @returns {vector_tile.Tile} Tile instance
         */
        Tile.create = function create(properties) {
            return new Tile(properties);
        };

        /**
         * Encodes the specified Tile message. Does not implicitly {@link vector_tile.Tile.verify|verify} messages.
         * @function encode
         * @memberof vector_tile.Tile
         * @static
         * @param {vector_tile.ITile} message Tile message or plain object to encode
         * @param {$protobuf.Writer} [writer] Writer to encode to
         * @returns {$protobuf.Writer} Writer
         */
        Tile.encode = function encode(message, writer) {
            if (!writer)
                writer = $Writer.create();
            if (message.layers != null && message.layers.length)
                for (var i = 0; i < message.layers.length; ++i)
                    $root.vector_tile.Tile.Layer.encode(message.layers[i], writer.uint32(/* id 3, wireType 2 =*/26).fork()).ldelim();
            return writer;
        };

        /**
         * Encodes the specified Tile message, length delimited. Does not implicitly {@link vector_tile.Tile.verify|verify} messages.
         * @function encodeDelimited
         * @memberof vector_tile.Tile
         * @static
         * @param {vector_tile.ITile} message Tile message or plain object to encode
         * @param {$protobuf.Writer} [writer] Writer to encode to
         * @returns {$protobuf.Writer} Writer
         */
        Tile.encodeDelimited = function encodeDelimited(message, writer) {
            return this.encode(message, writer).ldelim();
        };

        /**
         * Decodes a Tile message from the specified reader or buffer.
         * @function decode
         * @memberof vector_tile.Tile
         * @static
         * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
         * @param {number} [length] Message length if known beforehand
         * @returns {vector_tile.Tile} Tile
         * @throws {Error} If the payload is not a reader or valid buffer
         * @throws {$protobuf.util.ProtocolError} If required fields are missing
         */
        Tile.decode = function decode(reader, length, error) {
            if (!(reader instanceof $Reader))
                reader = $Reader.create(reader);
            var end = length === undefined ? reader.len : reader.pos + length, message = new $root.vector_tile.Tile();
            while (reader.pos < end) {
                var tag = reader.uint32();
                if (tag === error)
                    break;
                switch (tag >>> 3) {
                case 3: {
                        if (!(message.layers && message.layers.length))
                            message.layers = [];
                        message.layers.push($root.vector_tile.Tile.Layer.decode(reader, reader.uint32()));
                        break;
                    }
                default:
                    reader.skipType(tag & 7);
                    break;
                }
            }
            return message;
        };

        /**
         * Decodes a Tile message from the specified reader or buffer, length delimited.
         * @function decodeDelimited
         * @memberof vector_tile.Tile
         * @static
         * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
         * @returns {vector_tile.Tile} Tile
         * @throws {Error} If the payload is not a reader or valid buffer
         * @throws {$protobuf.util.ProtocolError} If required fields are missing
         */
        Tile.decodeDelimited = function decodeDelimited(reader) {
            if (!(reader instanceof $Reader))
                reader = new $Reader(reader);
            return this.decode(reader, reader.uint32());
        };

        /**
         * Verifies a Tile message.
         * @function verify
         * @memberof vector_tile.Tile
         * @static
         * @param {Object.<string,*>} message Plain object to verify
         * @returns {string|null} `null` if valid, otherwise the reason why it is not
         */
        Tile.verify = function verify(message) {
            if (typeof message !== "object" || message === null)
                return "object expected";
            if (message.layers != null && message.hasOwnProperty("layers")) {
                if (!Array.isArray(message.layers))
                    return "layers: array expected";
                for (var i = 0; i < message.layers.length; ++i) {
                    var error = $root.vector_tile.Tile.Layer.verify(message.layers[i]);
                    if (error)
                        return "layers." + error;
                }
            }
            return null;
        };

        /**
         * Creates a Tile message from a plain object. Also converts values to their respective internal types.
         * @function fromObject
         * @memberof vector_tile.Tile
         * @static
         * @param {Object.<string,*>} object Plain object
         * @returns {vector_tile.Tile} Tile
         */
        Tile.fromObject = function fromObject(object) {
            if (object instanceof $root.vector_tile.Tile)
                return object;
            var message = new $root.vector_tile.Tile();
            if (object.layers) {
                if (!Array.isArray(object.layers))
                    throw TypeError(".vector_tile.Tile.layers: array expected");
                message.layers = [];
                for (var i = 0; i < object.layers.length; ++i) {
                    if (typeof object.layers[i] !== "object")
                        throw TypeError(".vector_tile.Tile.layers: object expected");
                    message.layers[i] = $root.vector_tile.Tile.Layer.fromObject(object.layers[i]);
                }
            }
            return message;
        };

        /**
         * Creates a plain object from a Tile message. Also converts values to other types if specified.
         * @function toObject
         * @memberof vector_tile.Tile
         * @static
         * @param {vector_tile.Tile} message Tile
         * @param {$protobuf.IConversionOptions} [options] Conversion options
         * @returns {Object.<string,*>} Plain object
         */
        Tile.toObject = function toObject(message, options) {
            if (!options)
                options = {};
            var object = {};
            if (options.arrays || options.defaults)
                object.layers = [];
            if (message.layers && message.layers.length) {
                object.layers = [];
                for (var j = 0; j < message.layers.length; ++j)
                    object.layers[j] = $root.vector_tile.Tile.Layer.toObject(message.layers[j], options);
            }
            return object;
        };

        /**
         * Converts this Tile to JSON.
         * @function toJSON
         * @memberof vector_tile.Tile
         * @instance
         * @returns {Object.<string,*>} JSON object
         */
        Tile.prototype.toJSON = function toJSON() {
            return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
        };

        /**
         * Gets the default type url for Tile
         * @function getTypeUrl
         * @memberof vector_tile.Tile
         * @static
         * @param {string} [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
         * @returns {string} The default type url
         */
        Tile.getTypeUrl = function getTypeUrl(typeUrlPrefix) {
            if (typeUrlPrefix === undefined) {
                typeUrlPrefix = "type.googleapis.com";
            }
            return typeUrlPrefix + "/vector_tile.Tile";
        };

        /**
         * GeomType enum.
         * @name vector_tile.Tile.GeomType
         * @enum {number}
         * @property {number} UNKNOWN=0 UNKNOWN value
         * @property {number} POINT=1 POINT value
         * @property {number} LINESTRING=2 LINESTRING value
         * @property {number} POLYGON=3 POLYGON value
         */
        Tile.GeomType = (function() {
            var valuesById = {}, values = Object.create(valuesById);
            values[valuesById[0] = "UNKNOWN"] = 0;
            values[valuesById[1] = "POINT"] = 1;
            values[valuesById[2] = "LINESTRING"] = 2;
            values[valuesById[3] = "POLYGON"] = 3;
            return values;
        })();

        Tile.Value = (function() {

            /**
             * Properties of a Value.
             * @memberof vector_tile.Tile
             * @interface IValue
             * @property {string|null} [string_value] Value string_value
             * @property {number|null} [float_value] Value float_value
             * @property {number|null} [double_value] Value double_value
             * @property {number|Long|null} [int_value] Value int_value
             * @property {number|Long|null} [uint_value] Value uint_value
             * @property {number|Long|null} [sint_value] Value sint_value
             * @property {boolean|null} [bool_value] Value bool_value
             */

            /**
             * Constructs a new Value.
             * @memberof vector_tile.Tile
             * @classdesc Represents a Value.
             * @implements IValue
             * @constructor
             * @param {vector_tile.Tile.IValue=} [properties] Properties to set
             */
            function Value(properties) {
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * Value string_value.
             * @member {string} string_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.string_value = "";

            /**
             * Value float_value.
             * @member {number} float_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.float_value = 0;

            /**
             * Value double_value.
             * @member {number} double_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.double_value = 0;

            /**
             * Value int_value.
             * @member {number|Long} int_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.int_value = $util.Long ? $util.Long.fromBits(0,0,false) : 0;

            /**
             * Value uint_value.
             * @member {number|Long} uint_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.uint_value = $util.Long ? $util.Long.fromBits(0,0,true) : 0;

            /**
             * Value sint_value.
             * @member {number|Long} sint_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.sint_value = $util.Long ? $util.Long.fromBits(0,0,false) : 0;

            /**
             * Value bool_value.
             * @member {boolean} bool_value
             * @memberof vector_tile.Tile.Value
             * @instance
             */
            Value.prototype.bool_value = false;

            /**
             * Creates a new Value instance using the specified properties.
             * @function create
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {vector_tile.Tile.IValue=} [properties] Properties to set
             * @returns {vector_tile.Tile.Value} Value instance
             */
            Value.create = function create(properties) {
                return new Value(properties);
            };

            /**
             * Encodes the specified Value message. Does not implicitly {@link vector_tile.Tile.Value.verify|verify} messages.
             * @function encode
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {vector_tile.Tile.IValue} message Value message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Value.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                if (message.string_value != null && Object.hasOwnProperty.call(message, "string_value"))
                    writer.uint32(/* id 1, wireType 2 =*/10).string(message.string_value);
                if (message.float_value != null && Object.hasOwnProperty.call(message, "float_value"))
                    writer.uint32(/* id 2, wireType 5 =*/21).float(message.float_value);
                if (message.double_value != null && Object.hasOwnProperty.call(message, "double_value"))
                    writer.uint32(/* id 3, wireType 1 =*/25).double(message.double_value);
                if (message.int_value != null && Object.hasOwnProperty.call(message, "int_value"))
                    writer.uint32(/* id 4, wireType 0 =*/32).int64(message.int_value);
                if (message.uint_value != null && Object.hasOwnProperty.call(message, "uint_value"))
                    writer.uint32(/* id 5, wireType 0 =*/40).uint64(message.uint_value);
                if (message.sint_value != null && Object.hasOwnProperty.call(message, "sint_value"))
                    writer.uint32(/* id 6, wireType 0 =*/48).sint64(message.sint_value);
                if (message.bool_value != null && Object.hasOwnProperty.call(message, "bool_value"))
                    writer.uint32(/* id 7, wireType 0 =*/56).bool(message.bool_value);
                return writer;
            };

            /**
             * Encodes the specified Value message, length delimited. Does not implicitly {@link vector_tile.Tile.Value.verify|verify} messages.
             * @function encodeDelimited
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {vector_tile.Tile.IValue} message Value message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Value.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a Value message from the specified reader or buffer.
             * @function decode
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {vector_tile.Tile.Value} Value
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Value.decode = function decode(reader, length, error) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.vector_tile.Tile.Value();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    if (tag === error)
                        break;
                    switch (tag >>> 3) {
                    case 1: {
                            message.string_value = reader.string();
                            break;
                        }
                    case 2: {
                            message.float_value = reader.float();
                            break;
                        }
                    case 3: {
                            message.double_value = reader.double();
                            break;
                        }
                    case 4: {
                            message.int_value = reader.int64();
                            break;
                        }
                    case 5: {
                            message.uint_value = reader.uint64();
                            break;
                        }
                    case 6: {
                            message.sint_value = reader.sint64();
                            break;
                        }
                    case 7: {
                            message.bool_value = reader.bool();
                            break;
                        }
                    default:
                        reader.skipType(tag & 7);
                        break;
                    }
                }
                return message;
            };

            /**
             * Decodes a Value message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {vector_tile.Tile.Value} Value
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Value.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a Value message.
             * @function verify
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            Value.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (message.string_value != null && message.hasOwnProperty("string_value"))
                    if (!$util.isString(message.string_value))
                        return "string_value: string expected";
                if (message.float_value != null && message.hasOwnProperty("float_value"))
                    if (typeof message.float_value !== "number")
                        return "float_value: number expected";
                if (message.double_value != null && message.hasOwnProperty("double_value"))
                    if (typeof message.double_value !== "number")
                        return "double_value: number expected";
                if (message.int_value != null && message.hasOwnProperty("int_value"))
                    if (!$util.isInteger(message.int_value) && !(message.int_value && $util.isInteger(message.int_value.low) && $util.isInteger(message.int_value.high)))
                        return "int_value: integer|Long expected";
                if (message.uint_value != null && message.hasOwnProperty("uint_value"))
                    if (!$util.isInteger(message.uint_value) && !(message.uint_value && $util.isInteger(message.uint_value.low) && $util.isInteger(message.uint_value.high)))
                        return "uint_value: integer|Long expected";
                if (message.sint_value != null && message.hasOwnProperty("sint_value"))
                    if (!$util.isInteger(message.sint_value) && !(message.sint_value && $util.isInteger(message.sint_value.low) && $util.isInteger(message.sint_value.high)))
                        return "sint_value: integer|Long expected";
                if (message.bool_value != null && message.hasOwnProperty("bool_value"))
                    if (typeof message.bool_value !== "boolean")
                        return "bool_value: boolean expected";
                return null;
            };

            /**
             * Creates a Value message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {vector_tile.Tile.Value} Value
             */
            Value.fromObject = function fromObject(object) {
                if (object instanceof $root.vector_tile.Tile.Value)
                    return object;
                var message = new $root.vector_tile.Tile.Value();
                if (object.string_value != null)
                    message.string_value = String(object.string_value);
                if (object.float_value != null)
                    message.float_value = Number(object.float_value);
                if (object.double_value != null)
                    message.double_value = Number(object.double_value);
                if (object.int_value != null)
                    if ($util.Long)
                        (message.int_value = $util.Long.fromValue(object.int_value)).unsigned = false;
                    else if (typeof object.int_value === "string")
                        message.int_value = parseInt(object.int_value, 10);
                    else if (typeof object.int_value === "number")
                        message.int_value = object.int_value;
                    else if (typeof object.int_value === "object")
                        message.int_value = new $util.LongBits(object.int_value.low >>> 0, object.int_value.high >>> 0).toNumber();
                if (object.uint_value != null)
                    if ($util.Long)
                        (message.uint_value = $util.Long.fromValue(object.uint_value)).unsigned = true;
                    else if (typeof object.uint_value === "string")
                        message.uint_value = parseInt(object.uint_value, 10);
                    else if (typeof object.uint_value === "number")
                        message.uint_value = object.uint_value;
                    else if (typeof object.uint_value === "object")
                        message.uint_value = new $util.LongBits(object.uint_value.low >>> 0, object.uint_value.high >>> 0).toNumber(true);
                if (object.sint_value != null)
                    if ($util.Long)
                        (message.sint_value = $util.Long.fromValue(object.sint_value)).unsigned = false;
                    else if (typeof object.sint_value === "string")
                        message.sint_value = parseInt(object.sint_value, 10);
                    else if (typeof object.sint_value === "number")
                        message.sint_value = object.sint_value;
                    else if (typeof object.sint_value === "object")
                        message.sint_value = new $util.LongBits(object.sint_value.low >>> 0, object.sint_value.high >>> 0).toNumber();
                if (object.bool_value != null)
                    message.bool_value = Boolean(object.bool_value);
                return message;
            };

            /**
             * Creates a plain object from a Value message. Also converts values to other types if specified.
             * @function toObject
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {vector_tile.Tile.Value} message Value
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            Value.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.defaults) {
                    object.string_value = "";
                    object.float_value = 0;
                    object.double_value = 0;
                    if ($util.Long) {
                        var long = new $util.Long(0, 0, false);
                        object.int_value = options.longs === String ? long.toString() : options.longs === Number ? long.toNumber() : long;
                    } else
                        object.int_value = options.longs === String ? "0" : 0;
                    if ($util.Long) {
                        var long = new $util.Long(0, 0, true);
                        object.uint_value = options.longs === String ? long.toString() : options.longs === Number ? long.toNumber() : long;
                    } else
                        object.uint_value = options.longs === String ? "0" : 0;
                    if ($util.Long) {
                        var long = new $util.Long(0, 0, false);
                        object.sint_value = options.longs === String ? long.toString() : options.longs === Number ? long.toNumber() : long;
                    } else
                        object.sint_value = options.longs === String ? "0" : 0;
                    object.bool_value = false;
                }
                if (message.string_value != null && message.hasOwnProperty("string_value"))
                    object.string_value = message.string_value;
                if (message.float_value != null && message.hasOwnProperty("float_value"))
                    object.float_value = options.json && !isFinite(message.float_value) ? String(message.float_value) : message.float_value;
                if (message.double_value != null && message.hasOwnProperty("double_value"))
                    object.double_value = options.json && !isFinite(message.double_value) ? String(message.double_value) : message.double_value;
                if (message.int_value != null && message.hasOwnProperty("int_value"))
                    if (typeof message.int_value === "number")
                        object.int_value = options.longs === String ? String(message.int_value) : message.int_value;
                    else
                        object.int_value = options.longs === String ? $util.Long.prototype.toString.call(message.int_value) : options.longs === Number ? new $util.LongBits(message.int_value.low >>> 0, message.int_value.high >>> 0).toNumber() : message.int_value;
                if (message.uint_value != null && message.hasOwnProperty("uint_value"))
                    if (typeof message.uint_value === "number")
                        object.uint_value = options.longs === String ? String(message.uint_value) : message.uint_value;
                    else
                        object.uint_value = options.longs === String ? $util.Long.prototype.toString.call(message.uint_value) : options.longs === Number ? new $util.LongBits(message.uint_value.low >>> 0, message.uint_value.high >>> 0).toNumber(true) : message.uint_value;
                if (message.sint_value != null && message.hasOwnProperty("sint_value"))
                    if (typeof message.sint_value === "number")
                        object.sint_value = options.longs === String ? String(message.sint_value) : message.sint_value;
                    else
                        object.sint_value = options.longs === String ? $util.Long.prototype.toString.call(message.sint_value) : options.longs === Number ? new $util.LongBits(message.sint_value.low >>> 0, message.sint_value.high >>> 0).toNumber() : message.sint_value;
                if (message.bool_value != null && message.hasOwnProperty("bool_value"))
                    object.bool_value = message.bool_value;
                return object;
            };

            /**
             * Converts this Value to JSON.
             * @function toJSON
             * @memberof vector_tile.Tile.Value
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            Value.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            /**
             * Gets the default type url for Value
             * @function getTypeUrl
             * @memberof vector_tile.Tile.Value
             * @static
             * @param {string} [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
             * @returns {string} The default type url
             */
            Value.getTypeUrl = function getTypeUrl(typeUrlPrefix) {
                if (typeUrlPrefix === undefined) {
                    typeUrlPrefix = "type.googleapis.com";
                }
                return typeUrlPrefix + "/vector_tile.Tile.Value";
            };

            return Value;
        })();

        Tile.Feature = (function() {

            /**
             * Properties of a Feature.
             * @memberof vector_tile.Tile
             * @interface IFeature
             * @property {number|Long|null} [id] Feature id
             * @property {Array.<number>|null} [tags] Feature tags
             * @property {vector_tile.Tile.GeomType|null} [type] Feature type
             * @property {Array.<number>|null} [geometry] Feature geometry
             */

            /**
             * Constructs a new Feature.
             * @memberof vector_tile.Tile
             * @classdesc Represents a Feature.
             * @implements IFeature
             * @constructor
             * @param {vector_tile.Tile.IFeature=} [properties] Properties to set
             */
            function Feature(properties) {
                this.tags = [];
                this.geometry = [];
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * Feature id.
             * @member {number|Long} id
             * @memberof vector_tile.Tile.Feature
             * @instance
             */
            Feature.prototype.id = $util.Long ? $util.Long.fromBits(0,0,true) : 0;

            /**
             * Feature tags.
             * @member {Array.<number>} tags
             * @memberof vector_tile.Tile.Feature
             * @instance
             */
            Feature.prototype.tags = $util.emptyArray;

            /**
             * Feature type.
             * @member {vector_tile.Tile.GeomType} type
             * @memberof vector_tile.Tile.Feature
             * @instance
             */
            Feature.prototype.type = 0;

            /**
             * Feature geometry.
             * @member {Array.<number>} geometry
             * @memberof vector_tile.Tile.Feature
             * @instance
             */
            Feature.prototype.geometry = $util.emptyArray;

            /**
             * Creates a new Feature instance using the specified properties.
             * @function create
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {vector_tile.Tile.IFeature=} [properties] Properties to set
             * @returns {vector_tile.Tile.Feature} Feature instance
             */
            Feature.create = function create(properties) {
                return new Feature(properties);
            };

            /**
             * Encodes the specified Feature message. Does not implicitly {@link vector_tile.Tile.Feature.verify|verify} messages.
             * @function encode
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {vector_tile.Tile.IFeature} message Feature message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Feature.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                if (message.id != null && Object.hasOwnProperty.call(message, "id"))
                    writer.uint32(/* id 1, wireType 0 =*/8).uint64(message.id);
                if (message.tags != null && message.tags.length) {
                    writer.uint32(/* id 2, wireType 2 =*/18).fork();
                    for (var i = 0; i < message.tags.length; ++i)
                        writer.uint32(message.tags[i]);
                    writer.ldelim();
                }
                if (message.type != null && Object.hasOwnProperty.call(message, "type"))
                    writer.uint32(/* id 3, wireType 0 =*/24).int32(message.type);
                if (message.geometry != null && message.geometry.length) {
                    writer.uint32(/* id 4, wireType 2 =*/34).fork();
                    for (var i = 0; i < message.geometry.length; ++i)
                        writer.uint32(message.geometry[i]);
                    writer.ldelim();
                }
                return writer;
            };

            /**
             * Encodes the specified Feature message, length delimited. Does not implicitly {@link vector_tile.Tile.Feature.verify|verify} messages.
             * @function encodeDelimited
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {vector_tile.Tile.IFeature} message Feature message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Feature.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a Feature message from the specified reader or buffer.
             * @function decode
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {vector_tile.Tile.Feature} Feature
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Feature.decode = function decode(reader, length, error) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.vector_tile.Tile.Feature();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    if (tag === error)
                        break;
                    switch (tag >>> 3) {
                    case 1: {
                            message.id = reader.uint64();
                            break;
                        }
                    case 2: {
                            if (!(message.tags && message.tags.length))
                                message.tags = [];
                            if ((tag & 7) === 2) {
                                var end2 = reader.uint32() + reader.pos;
                                while (reader.pos < end2)
                                    message.tags.push(reader.uint32());
                            } else
                                message.tags.push(reader.uint32());
                            break;
                        }
                    case 3: {
                            message.type = reader.int32();
                            break;
                        }
                    case 4: {
                            if (!(message.geometry && message.geometry.length))
                                message.geometry = [];
                            if ((tag & 7) === 2) {
                                var end2 = reader.uint32() + reader.pos;
                                while (reader.pos < end2)
                                    message.geometry.push(reader.uint32());
                            } else
                                message.geometry.push(reader.uint32());
                            break;
                        }
                    default:
                        reader.skipType(tag & 7);
                        break;
                    }
                }
                return message;
            };

            /**
             * Decodes a Feature message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {vector_tile.Tile.Feature} Feature
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Feature.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a Feature message.
             * @function verify
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            Feature.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (message.id != null && message.hasOwnProperty("id"))
                    if (!$util.isInteger(message.id) && !(message.id && $util.isInteger(message.id.low) && $util.isInteger(message.id.high)))
                        return "id: integer|Long expected";
                if (message.tags != null && message.hasOwnProperty("tags")) {
                    if (!Array.isArray(message.tags))
                        return "tags: array expected";
                    for (var i = 0; i < message.tags.length; ++i)
                        if (!$util.isInteger(message.tags[i]))
                            return "tags: integer[] expected";
                }
                if (message.type != null && message.hasOwnProperty("type"))
                    switch (message.type) {
                    default:
                        return "type: enum value expected";
                    case 0:
                    case 1:
                    case 2:
                    case 3:
                        break;
                    }
                if (message.geometry != null && message.hasOwnProperty("geometry")) {
                    if (!Array.isArray(message.geometry))
                        return "geometry: array expected";
                    for (var i = 0; i < message.geometry.length; ++i)
                        if (!$util.isInteger(message.geometry[i]))
                            return "geometry: integer[] expected";
                }
                return null;
            };

            /**
             * Creates a Feature message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {vector_tile.Tile.Feature} Feature
             */
            Feature.fromObject = function fromObject(object) {
                if (object instanceof $root.vector_tile.Tile.Feature)
                    return object;
                var message = new $root.vector_tile.Tile.Feature();
                if (object.id != null)
                    if ($util.Long)
                        (message.id = $util.Long.fromValue(object.id)).unsigned = true;
                    else if (typeof object.id === "string")
                        message.id = parseInt(object.id, 10);
                    else if (typeof object.id === "number")
                        message.id = object.id;
                    else if (typeof object.id === "object")
                        message.id = new $util.LongBits(object.id.low >>> 0, object.id.high >>> 0).toNumber(true);
                if (object.tags) {
                    if (!Array.isArray(object.tags))
                        throw TypeError(".vector_tile.Tile.Feature.tags: array expected");
                    message.tags = [];
                    for (var i = 0; i < object.tags.length; ++i)
                        message.tags[i] = object.tags[i] >>> 0;
                }
                switch (object.type) {
                default:
                    if (typeof object.type === "number") {
                        message.type = object.type;
                        break;
                    }
                    break;
                case "UNKNOWN":
                case 0:
                    message.type = 0;
                    break;
                case "POINT":
                case 1:
                    message.type = 1;
                    break;
                case "LINESTRING":
                case 2:
                    message.type = 2;
                    break;
                case "POLYGON":
                case 3:
                    message.type = 3;
                    break;
                }
                if (object.geometry) {
                    if (!Array.isArray(object.geometry))
                        throw TypeError(".vector_tile.Tile.Feature.geometry: array expected");
                    message.geometry = [];
                    for (var i = 0; i < object.geometry.length; ++i)
                        message.geometry[i] = object.geometry[i] >>> 0;
                }
                return message;
            };

            /**
             * Creates a plain object from a Feature message. Also converts values to other types if specified.
             * @function toObject
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {vector_tile.Tile.Feature} message Feature
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            Feature.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.arrays || options.defaults) {
                    object.tags = [];
                    object.geometry = [];
                }
                if (options.defaults) {
                    if ($util.Long) {
                        var long = new $util.Long(0, 0, true);
                        object.id = options.longs === String ? long.toString() : options.longs === Number ? long.toNumber() : long;
                    } else
                        object.id = options.longs === String ? "0" : 0;
                    object.type = options.enums === String ? "UNKNOWN" : 0;
                }
                if (message.id != null && message.hasOwnProperty("id"))
                    if (typeof message.id === "number")
                        object.id = options.longs === String ? String(message.id) : message.id;
                    else
                        object.id = options.longs === String ? $util.Long.prototype.toString.call(message.id) : options.longs === Number ? new $util.LongBits(message.id.low >>> 0, message.id.high >>> 0).toNumber(true) : message.id;
                if (message.tags && message.tags.length) {
                    object.tags = [];
                    for (var j = 0; j < message.tags.length; ++j)
                        object.tags[j] = message.tags[j];
                }
                if (message.type != null && message.hasOwnProperty("type"))
                    object.type = options.enums === String ? $root.vector_tile.Tile.GeomType[message.type] === undefined ? message.type : $root.vector_tile.Tile.GeomType[message.type] : message.type;
                if (message.geometry && message.geometry.length) {
                    object.geometry = [];
                    for (var j = 0; j < message.geometry.length; ++j)
                        object.geometry[j] = message.geometry[j];
                }
                return object;
            };

            /**
             * Converts this Feature to JSON.
             * @function toJSON
             * @memberof vector_tile.Tile.Feature
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            Feature.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            /**
             * Gets the default type url for Feature
             * @function getTypeUrl
             * @memberof vector_tile.Tile.Feature
             * @static
             * @param {string} [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
             * @returns {string} The default type url
             */
            Feature.getTypeUrl = function getTypeUrl(typeUrlPrefix) {
                if (typeUrlPrefix === undefined) {
                    typeUrlPrefix = "type.googleapis.com";
                }
                return typeUrlPrefix + "/vector_tile.Tile.Feature";
            };

            return Feature;
        })();

        Tile.Layer = (function() {

            /**
             * Properties of a Layer.
             * @memberof vector_tile.Tile
             * @interface ILayer
             * @property {number} version Layer version
             * @property {string} name Layer name
             * @property {Array.<vector_tile.Tile.IFeature>|null} [features] Layer features
             * @property {Array.<string>|null} [keys] Layer keys
             * @property {Array.<vector_tile.Tile.IValue>|null} [values] Layer values
             * @property {number|null} [extent] Layer extent
             */

            /**
             * Constructs a new Layer.
             * @memberof vector_tile.Tile
             * @classdesc Represents a Layer.
             * @implements ILayer
             * @constructor
             * @param {vector_tile.Tile.ILayer=} [properties] Properties to set
             */
            function Layer(properties) {
                this.features = [];
                this.keys = [];
                this.values = [];
                if (properties)
                    for (var keys = Object.keys(properties), i = 0; i < keys.length; ++i)
                        if (properties[keys[i]] != null)
                            this[keys[i]] = properties[keys[i]];
            }

            /**
             * Layer version.
             * @member {number} version
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.version = 1;

            /**
             * Layer name.
             * @member {string} name
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.name = "";

            /**
             * Layer features.
             * @member {Array.<vector_tile.Tile.IFeature>} features
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.features = $util.emptyArray;

            /**
             * Layer keys.
             * @member {Array.<string>} keys
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.keys = $util.emptyArray;

            /**
             * Layer values.
             * @member {Array.<vector_tile.Tile.IValue>} values
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.values = $util.emptyArray;

            /**
             * Layer extent.
             * @member {number} extent
             * @memberof vector_tile.Tile.Layer
             * @instance
             */
            Layer.prototype.extent = 4096;

            /**
             * Creates a new Layer instance using the specified properties.
             * @function create
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {vector_tile.Tile.ILayer=} [properties] Properties to set
             * @returns {vector_tile.Tile.Layer} Layer instance
             */
            Layer.create = function create(properties) {
                return new Layer(properties);
            };

            /**
             * Encodes the specified Layer message. Does not implicitly {@link vector_tile.Tile.Layer.verify|verify} messages.
             * @function encode
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {vector_tile.Tile.ILayer} message Layer message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Layer.encode = function encode(message, writer) {
                if (!writer)
                    writer = $Writer.create();
                writer.uint32(/* id 1, wireType 2 =*/10).string(message.name);
                if (message.features != null && message.features.length)
                    for (var i = 0; i < message.features.length; ++i)
                        $root.vector_tile.Tile.Feature.encode(message.features[i], writer.uint32(/* id 2, wireType 2 =*/18).fork()).ldelim();
                if (message.keys != null && message.keys.length)
                    for (var i = 0; i < message.keys.length; ++i)
                        writer.uint32(/* id 3, wireType 2 =*/26).string(message.keys[i]);
                if (message.values != null && message.values.length)
                    for (var i = 0; i < message.values.length; ++i)
                        $root.vector_tile.Tile.Value.encode(message.values[i], writer.uint32(/* id 4, wireType 2 =*/34).fork()).ldelim();
                if (message.extent != null && Object.hasOwnProperty.call(message, "extent"))
                    writer.uint32(/* id 5, wireType 0 =*/40).uint32(message.extent);
                writer.uint32(/* id 15, wireType 0 =*/120).uint32(message.version);
                return writer;
            };

            /**
             * Encodes the specified Layer message, length delimited. Does not implicitly {@link vector_tile.Tile.Layer.verify|verify} messages.
             * @function encodeDelimited
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {vector_tile.Tile.ILayer} message Layer message or plain object to encode
             * @param {$protobuf.Writer} [writer] Writer to encode to
             * @returns {$protobuf.Writer} Writer
             */
            Layer.encodeDelimited = function encodeDelimited(message, writer) {
                return this.encode(message, writer).ldelim();
            };

            /**
             * Decodes a Layer message from the specified reader or buffer.
             * @function decode
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @param {number} [length] Message length if known beforehand
             * @returns {vector_tile.Tile.Layer} Layer
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Layer.decode = function decode(reader, length, error) {
                if (!(reader instanceof $Reader))
                    reader = $Reader.create(reader);
                var end = length === undefined ? reader.len : reader.pos + length, message = new $root.vector_tile.Tile.Layer();
                while (reader.pos < end) {
                    var tag = reader.uint32();
                    if (tag === error)
                        break;
                    switch (tag >>> 3) {
                    case 15: {
                            message.version = reader.uint32();
                            break;
                        }
                    case 1: {
                            message.name = reader.string();
                            break;
                        }
                    case 2: {
                            if (!(message.features && message.features.length))
                                message.features = [];
                            message.features.push($root.vector_tile.Tile.Feature.decode(reader, reader.uint32()));
                            break;
                        }
                    case 3: {
                            if (!(message.keys && message.keys.length))
                                message.keys = [];
                            message.keys.push(reader.string());
                            break;
                        }
                    case 4: {
                            if (!(message.values && message.values.length))
                                message.values = [];
                            message.values.push($root.vector_tile.Tile.Value.decode(reader, reader.uint32()));
                            break;
                        }
                    case 5: {
                            message.extent = reader.uint32();
                            break;
                        }
                    default:
                        reader.skipType(tag & 7);
                        break;
                    }
                }
                if (!message.hasOwnProperty("version"))
                    throw $util.ProtocolError("missing required 'version'", { instance: message });
                if (!message.hasOwnProperty("name"))
                    throw $util.ProtocolError("missing required 'name'", { instance: message });
                return message;
            };

            /**
             * Decodes a Layer message from the specified reader or buffer, length delimited.
             * @function decodeDelimited
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {$protobuf.Reader|Uint8Array} reader Reader or buffer to decode from
             * @returns {vector_tile.Tile.Layer} Layer
             * @throws {Error} If the payload is not a reader or valid buffer
             * @throws {$protobuf.util.ProtocolError} If required fields are missing
             */
            Layer.decodeDelimited = function decodeDelimited(reader) {
                if (!(reader instanceof $Reader))
                    reader = new $Reader(reader);
                return this.decode(reader, reader.uint32());
            };

            /**
             * Verifies a Layer message.
             * @function verify
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {Object.<string,*>} message Plain object to verify
             * @returns {string|null} `null` if valid, otherwise the reason why it is not
             */
            Layer.verify = function verify(message) {
                if (typeof message !== "object" || message === null)
                    return "object expected";
                if (!$util.isInteger(message.version))
                    return "version: integer expected";
                if (!$util.isString(message.name))
                    return "name: string expected";
                if (message.features != null && message.hasOwnProperty("features")) {
                    if (!Array.isArray(message.features))
                        return "features: array expected";
                    for (var i = 0; i < message.features.length; ++i) {
                        var error = $root.vector_tile.Tile.Feature.verify(message.features[i]);
                        if (error)
                            return "features." + error;
                    }
                }
                if (message.keys != null && message.hasOwnProperty("keys")) {
                    if (!Array.isArray(message.keys))
                        return "keys: array expected";
                    for (var i = 0; i < message.keys.length; ++i)
                        if (!$util.isString(message.keys[i]))
                            return "keys: string[] expected";
                }
                if (message.values != null && message.hasOwnProperty("values")) {
                    if (!Array.isArray(message.values))
                        return "values: array expected";
                    for (var i = 0; i < message.values.length; ++i) {
                        var error = $root.vector_tile.Tile.Value.verify(message.values[i]);
                        if (error)
                            return "values." + error;
                    }
                }
                if (message.extent != null && message.hasOwnProperty("extent"))
                    if (!$util.isInteger(message.extent))
                        return "extent: integer expected";
                return null;
            };

            /**
             * Creates a Layer message from a plain object. Also converts values to their respective internal types.
             * @function fromObject
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {Object.<string,*>} object Plain object
             * @returns {vector_tile.Tile.Layer} Layer
             */
            Layer.fromObject = function fromObject(object) {
                if (object instanceof $root.vector_tile.Tile.Layer)
                    return object;
                var message = new $root.vector_tile.Tile.Layer();
                if (object.version != null)
                    message.version = object.version >>> 0;
                if (object.name != null)
                    message.name = String(object.name);
                if (object.features) {
                    if (!Array.isArray(object.features))
                        throw TypeError(".vector_tile.Tile.Layer.features: array expected");
                    message.features = [];
                    for (var i = 0; i < object.features.length; ++i) {
                        if (typeof object.features[i] !== "object")
                            throw TypeError(".vector_tile.Tile.Layer.features: object expected");
                        message.features[i] = $root.vector_tile.Tile.Feature.fromObject(object.features[i]);
                    }
                }
                if (object.keys) {
                    if (!Array.isArray(object.keys))
                        throw TypeError(".vector_tile.Tile.Layer.keys: array expected");
                    message.keys = [];
                    for (var i = 0; i < object.keys.length; ++i)
                        message.keys[i] = String(object.keys[i]);
                }
                if (object.values) {
                    if (!Array.isArray(object.values))
                        throw TypeError(".vector_tile.Tile.Layer.values: array expected");
                    message.values = [];
                    for (var i = 0; i < object.values.length; ++i) {
                        if (typeof object.values[i] !== "object")
                            throw TypeError(".vector_tile.Tile.Layer.values: object expected");
                        message.values[i] = $root.vector_tile.Tile.Value.fromObject(object.values[i]);
                    }
                }
                if (object.extent != null)
                    message.extent = object.extent >>> 0;
                return message;
            };

            /**
             * Creates a plain object from a Layer message. Also converts values to other types if specified.
             * @function toObject
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {vector_tile.Tile.Layer} message Layer
             * @param {$protobuf.IConversionOptions} [options] Conversion options
             * @returns {Object.<string,*>} Plain object
             */
            Layer.toObject = function toObject(message, options) {
                if (!options)
                    options = {};
                var object = {};
                if (options.arrays || options.defaults) {
                    object.features = [];
                    object.keys = [];
                    object.values = [];
                }
                if (options.defaults) {
                    object.name = "";
                    object.extent = 4096;
                    object.version = 1;
                }
                if (message.name != null && message.hasOwnProperty("name"))
                    object.name = message.name;
                if (message.features && message.features.length) {
                    object.features = [];
                    for (var j = 0; j < message.features.length; ++j)
                        object.features[j] = $root.vector_tile.Tile.Feature.toObject(message.features[j], options);
                }
                if (message.keys && message.keys.length) {
                    object.keys = [];
                    for (var j = 0; j < message.keys.length; ++j)
                        object.keys[j] = message.keys[j];
                }
                if (message.values && message.values.length) {
                    object.values = [];
                    for (var j = 0; j < message.values.length; ++j)
                        object.values[j] = $root.vector_tile.Tile.Value.toObject(message.values[j], options);
                }
                if (message.extent != null && message.hasOwnProperty("extent"))
                    object.extent = message.extent;
                if (message.version != null && message.hasOwnProperty("version"))
                    object.version = message.version;
                return object;
            };

            /**
             * Converts this Layer to JSON.
             * @function toJSON
             * @memberof vector_tile.Tile.Layer
             * @instance
             * @returns {Object.<string,*>} JSON object
             */
            Layer.prototype.toJSON = function toJSON() {
                return this.constructor.toObject(this, $protobuf.util.toJSONOptions);
            };

            /**
             * Gets the default type url for Layer
             * @function getTypeUrl
             * @memberof vector_tile.Tile.Layer
             * @static
             * @param {string} [typeUrlPrefix] your custom typeUrlPrefix(default "type.googleapis.com")
             * @returns {string} The default type url
             */
            Layer.getTypeUrl = function getTypeUrl(typeUrlPrefix) {
                if (typeUrlPrefix === undefined) {
                    typeUrlPrefix = "type.googleapis.com";
                }
                return typeUrlPrefix + "/vector_tile.Tile.Layer";
            };

            return Layer;
        })();

        return Tile;
    })();

    return vector_tile;
})();

module.exports = $root;
