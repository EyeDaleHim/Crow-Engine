package crow.assets.format;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import haxe.Int64;
import haxe.Json;
import haxe.xml.Parser;

/**
 * MessagePack serialization and deserialization.
 * 
 * Not verified to work on all targets.
 *
 * @see https://github.com/msgpack/msgpack/blob/master/spec.md
 */
class MessagePack
{
	/**
	 * Parses MessagePack-encoded bytes into a Haxe dynamic object.
	 * @param bytes The MessagePack-encoded `Bytes`.
	 * @return The deserialized Haxe object.
	 */
	public static function parse(bytes:Bytes):Dynamic
	{
		final input = new BytesInput(bytes);
		return new MessagePackReader(input).read();
	}

	/**
	 * Serializes a Haxe dynamic object into MessagePack-encoded bytes.
	 * @param obj The Haxe object to serialize.
	 * @return The MessagePack-encoded `Bytes`.
	 */
	public static function serialize(obj:Dynamic):Bytes
	{
		final buffer = new BytesBuffer();
		new MessagePackWriter(buffer).write(obj);
		return buffer.getBytes();
	}

	/**
	 * Converts a Haxe dynamic object into a JSON-formatted string.
	 * This is a convenience function, equivalent to `haxe.Json.stringify`.
	 * @param obj The Haxe object to stringify.
	 * @param pretty Whether to format the JSON with indentation for readability.
	 * @return The JSON string representation of the object.
	 */
	public static function stringify(obj:Dynamic, pretty:Bool = false):String
	{
		return Json.stringify(obj, null, pretty ? "  " : null);
	}
}

private class MessagePackReader
{
	var input:BytesInput;

	public function new(input:BytesInput)
	{
		this.input = input;
	}

	public function read():Dynamic
	{
		final b = input.readByte();

		// positive fixint
		if (b >= 0x00 && b <= 0x7f)
			return b;

		// fixmap
		if (b >= 0x80 && b <= 0x8f)
			return readMap(b & 0x0f);

		// fixarray
		if (b >= 0x90 && b <= 0x9f)
			return readArray(b & 0x0f);

		// fixstr
		if (b >= 0xa0 && b <= 0xbf)
			return readString(b & 0x1f);

		// negative fixint
		if (b >= 0xe0 && b <= 0xff)
			return b - 256;

		switch (b)
		{
			case 0xc0: // nil
				return null;
			case 0xc1: // never used
				throw "Invalid MessagePack format: never used byte 0xc1";
			case 0xc2: // false
				return false;
			case 0xc3: // true
				return true;
			case 0xc4: // bin 8
				return input.read(input.readByte());
			case 0xc5: // bin 16
				return input.read(readUInt16());
			case 0xc6: // bin 32
				return input.read(input.readInt32());
			case 0xc7: // ext 8
				return readExt(input.readByte());
			case 0xc8: // ext 16
				return readExt(readUInt16());
			case 0xc9: // ext 32
				return readExt(input.readInt32());
			case 0xca: // float 32
				return input.readFloat();
			case 0xcb: // float 64
				return input.readDouble();
			case 0xcc: // uint 8
				return input.readByte();
			case 0xcd: // uint 16
				return readUInt16();
			case 0xce: // uint 32
				return input.readInt32();
			case 0xcf: // uint 64
				return readInt64(); // Using readInt64 for both, as Haxe's Int64 handles the full range.
			case 0xd0: // int 8
				return readSByte();
			case 0xd1: // int 16
				return readInt16();
			case 0xd2: // int 32
				return input.readInt32();
			case 0xd3: // int 64
				return readInt64();
			case 0xd4: // fixext 1
				return readExt(1);
			case 0xd5: // fixext 2
				return readExt(2);
			case 0xd6: // fixext 4
				return readExt(4);
			case 0xd7: // fixext 8
				return readExt(8);
			case 0xd8: // fixext 16
				return readExt(16);
			case 0xd9: // str 8
				return readString(input.readByte());
			case 0xda: // str 16
				return readString(readUInt16());
			case 0xdb: // str 32
				return readString(input.readInt32());
			case 0xdc: // array 16
				return readArray(readUInt16());
			case 0xdd: // array 32
				return readArray(input.readInt32());
			case 0xde: // map 16
				return readMap(readUInt16());
			case 0xdf: // map 32
				return readMap(input.readInt32());
			default:
				throw 'Invalid MessagePack format byte: ${b}';
		}
	}

	function readString(len:Int):String
	{
		return input.read(len).toString();
	}

	function readArray(len:Int):Array<Dynamic>
	{
		var a = [];
		for (i in 0...len)
		{
			a.push(read());
		}
		return a;
	}

	function readMap(len:Int):Dynamic
	{
		var obj:Dynamic = {};
		for (i in 0...len)
		{
			var key = read();
			var value = read();
			Reflect.setField(obj, key, value);
		}
		return obj;
	}

	// Helper to read a signed 8-bit integer
	function readSByte():Int
	{
		var b = input.readByte();
		return (b > 127) ? (b - 256) : b;
	}

	// Helper to read a 16-bit unsigned integer (big-endian)
	function readUInt16():Int
	{
		final high = input.readByte();
		final low = input.readByte();
		return (high << 8) | low;
	}

	// Helper to read a 16-bit signed integer (big-endian)
	function readInt16():Int
	{
		var val = input.readUInt16();
		// If the sign bit is set, convert from unsigned to signed
		return (val & 0x8000) != 0 ? val - 0x10000 : val;
	}

	// Helper to read a 64-bit signed integer (big-endian)
	function readInt64():Int64
	{
		var high = input.readInt32();
		var low = input.readInt32();
		return Int64.make(high, low);
	}

	function readExt(len:Int):Dynamic
	{
		var type = readSByte();
		var data = input.read(len);

		return {extType: type, data: data};
	}
}

private class MessagePackWriter
{
	var buffer:BytesBuffer;

	public function new(buffer:BytesBuffer)
	{
		this.buffer = buffer;
	}

	public function write(v:Dynamic)
	{
		if (v == null)
		{
			buffer.addByte(0xc0); // nil
			return;
		}

		if (v is Bool)
		{
			buffer.addByte(v ? 0xc3 : 0xc2); // true/false
			return;
		}

		if (v is Int)
		{
			writeInt(v);
			return;
		}

		if (v is Float)
		{
			// Haxe Int can be implicitly converted to Float, so check if it's a whole number first
			var intVal:Int = Std.int(v);
			if (intVal == v)
			{
				writeInt(intVal);
			}
			else
			{
				buffer.addByte(0xcb); // float 64
				buffer.addDouble(v);
			}
			return;
		}

		if (v is String)
		{
			writeString(v);
			return;
		}

		if (v is Array)
		{
			writeArray(v);
			return;
		}

		if (v is Bytes)
		{
			writeBin(v);
			return;
		}

		// Check for extension type object {extType: Int, data: Bytes}
		if (Reflect.isObject(v) && Reflect.hasField(v, "extType") && Reflect.hasField(v, "data"))
		{
			var data:Bytes = Reflect.field(v, "data");
			if (data != null && data is Bytes)
			{
				var extType:Int = Reflect.field(v, "extType");
				writeExt(extType, data);
				return;
			}
		}

		if (Reflect.isObject(v))
		{
			writeMap(v);
			return;
		}

		// Since Int64 is an abstract, we can't use `is` or `isOfType`.
		// The most reliable cross-platform way to check is to try an Int64 operation.
		try
		{
			// This will only succeed if `v` is a valid Int64.
			// It's a "no-op" that forces a type check.
			var i64:Int64 = v;
			writeInt64(i64);
			return;
		}
		catch (e:Dynamic)
		{
			// Not an Int64, proceed to other type checks.
		}

		throw "Unsupported type for MessagePack serialization: " + Type.typeof(v);
	}

	function writeInt(v:Int)
	{
		if (v >= 0)
		{
			if (v <= 0x7f)
			{ // positive fixint
				buffer.addByte(v);
			}
			else if (v <= 0xff)
			{ // uint 8
				buffer.addByte(0xcc);
				buffer.addByte(v);
			}
			else if (v <= 0xffff)
			{ // uint 16
				buffer.addByte(0xcd);
				writeUInt16(v);
			}
			else
			{ // uint 32 / int 32
				buffer.addByte(0xce);
				buffer.addInt32(v);
			}
		}
		else
		{ // Negative
			if (v >= -32)
			{ // negative fixint
				// Haxe's addByte takes an Int, but it's treated as unsigned.
				// For negative fixint, the byte value is 0b111xxxxx.
				// If v is -1 (0b11111111), addByte(-1) will write 255 (0xFF).
				// If v is -32 (0b11100000), addByte(-32) will write 224 (0xE0).
				buffer.addByte(v);
			}
			else if (v >= -128)
			{ // int 8
				buffer.addByte(0xd0);
				buffer.addByte(v);
			}
			else if (v >= -32768)
			{ // int 16
				buffer.addByte(0xd1);
				writeInt16(v);
			}
			else
			{ // int 32
				buffer.addByte(0xd2);
				buffer.addInt32(v);
			}
		}
	}

	// Helper to write a 16-bit unsigned integer (big-endian)
	function writeUInt16(v:Int)
	{
		buffer.addByte((v >> 8) & 0xFF);
		buffer.addByte(v & 0xFF);
	}

	// i have to write this because someone at the Haxe team did not
	// add 16-bit functions
	function writeInt16(v:Int)
	{
		buffer.addByte((v >> 8) & 0xFF);
		buffer.addByte(v & 0xFF);
	}

	function writeInt64(v:Int64)
	{
		// For simplicity, we'll just use int 64 format for all Int64 values.
		// Optimizations could check if the value fits in smaller integer types.
		buffer.addByte(0xd3); // int 64
		buffer.addInt32(Int64.getHigh(v));
		buffer.addInt32(Int64.getLow(v));
	}

	function writeString(s:String)
	{
		var bytes = Bytes.ofString(s);
		var len = bytes.length;

		if (len <= 31)
		{ // fixstr
			buffer.addByte(0xa0 | len);
		}
		else if (len <= 0xff)
		{ // str 8
			buffer.addByte(0xd9);
			buffer.addByte(len); // len is unsigned 8-bit
		}
		else if (len <= 0xffff)
		{ // str 16
			buffer.addByte(0xda);
			writeUInt16(len);
		}
		else
		{ // str 32
			buffer.addByte(0xdb);
			buffer.addInt32(len);
		}
		buffer.add(bytes);
	}

	function writeBin(b:Bytes)
	{
		var len = b.length;
		if (len <= 0xff)
		{ // bin 8
			buffer.addByte(0xc4);
			buffer.addByte(len); // len is unsigned 8-bit
		}
		else if (len <= 0xffff)
		{ // bin 16
			buffer.addByte(0xc5);
			writeUInt16(len);
		}
		else
		{ // bin 32
			buffer.addByte(0xc6);
			buffer.addInt32(len);
		}
		buffer.add(b);
	}

	function writeArray(a:Array<Dynamic>)
	{
		var len = a.length;
		if (len <= 15)
		{ // fixarray
			buffer.addByte(0x90 | len);
		}
		else if (len <= 0xffff)
		{ // array 16
			buffer.addByte(0xdc);
			writeUInt16(len);
		}
		else
		{ // array 32
			buffer.addByte(0xdd);
			buffer.addInt32(len);
		}
		for (item in a)
		{
			write(item);
		}
	}

	function writeMap(o:Dynamic)
	{
		var fields = Reflect.fields(o);
		var len = fields.length;

		if (len <= 15)
		{ // fixmap
			buffer.addByte(0x80 | len);
		}
		else if (len <= 0xffff)
		{ // map 16
			buffer.addByte(0xde);
			writeUInt16(len);
		}
		else
		{ // map 32
			buffer.addByte(0xdf);
			buffer.addInt32(len);
		}

		for (field in fields)
		{
			writeString(field);
			write(Reflect.field(o, field));
		}
	}

	function writeExt(extType:Int, data:Bytes)
	{
		var len = data.length;
		switch (len)
		{
			case 1:
				buffer.addByte(0xd4); // fixext 1
			case 2:
				buffer.addByte(0xd5); // fixext 2
			case 4:
				buffer.addByte(0xd6); // fixext 4
			case 8:
				buffer.addByte(0xd7); // fixext 8
			case 16:
				buffer.addByte(0xd8); // fixext 16
			default:
				if (len <= 0xff)
				{ // ext 8
					buffer.addByte(0xc7);
					buffer.addByte(len); // len is unsigned 8-bit
				}
				else if (len <= 0xffff)
				{ // ext 16
					buffer.addByte(0xc8);
					writeUInt16(len);
				}
				else
				{ // ext 32
					buffer.addByte(0xc9);
					buffer.addInt32(len);
				}
		}
		buffer.addByte(extType);
		buffer.add(data);
	}
}