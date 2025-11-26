package crow.utils;

import haxe.io.Bytes;

/**
 * Attempt to read width / height / header-size of an ATF file.
 * Supports both 3-byte and 4-byte length-field variants.
 */
class ATFUtil
{
	public static function getATFInfo(bytes:haxe.io.Bytes):{width:Int, height:Int, bodyOffset:Int}
	{
		if (bytes == null || bytes.length < 7)
		{
			return null;
		}

		// signature check
		try
		{
			if (bytes.getString(0, 3) != "ATF")
			{
				return null;
			}
		}
		catch (e:Dynamic)
		{
			return null;
		}

		var offset = 0;
		// we look at byte 6 to detect 4-byte length marker
		if (bytes.length < 7)
		{
			return null;
		}

		var b6 = bytes.get(6) & 0xFF;
		var version = 0;
		var bodyLength:Int;

		if (b6 == 0xFF)
		{
			// versioned ATF: next byte is version, then 4-byte BE length
			version = bytes.get(7) & 0xFF;
			if (bytes.length < 8 + 4)
			{
				return null;
			}
			bodyLength = ((bytes.get(8) & 0xFF) << 24) | ((bytes.get(9) & 0xFF) << 16) | ((bytes.get(10) & 0xFF) << 8) | (bytes.get(11) & 0xFF);
			offset = 8 + 4;
		}
		else
		{
			// legacy ATF: 3-byte BE length at offset 3
			if (bytes.length < 6)
			{
				return null;
			}
			bodyLength = ((bytes.get(3) & 0xFF) << 16) | ((bytes.get(4) & 0xFF) << 8) | (bytes.get(5) & 0xFF);
			offset = 6;
		}

		// Sanity: bodyLength must not exceed remaining bytes
		if (bodyLength > bytes.length - offset)
		{
			return null;
		}

		// Now read flags byte
		if (bytes.length <= offset)
		{
			return null;
		}
		var flags = bytes.get(offset) & 0xFF;
		offset += 1;

		// Read width and height exponents
		if (bytes.length <= offset + 1)
		{
			return null;
		}
		var width = 1 << (bytes.get(offset) & 0xFF);
		offset += 1;
		var height = 1 << (bytes.get(offset) & 0xFF);
		offset += 1;

		// skip mip-count
		offset += 1;

		// compute where the body data (compressed texture data) starts
		var bodyOffset:Int = offset;

		return {width: width, height: height, bodyOffset: bodyOffset};
	}
}
