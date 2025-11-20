package crow.assets.format;

#if !macro
import openfl.display.PNGEncoderOptions;
import flixel.system.FlxAssets.FlxXmlAsset;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import haxe.crypto.Sha1;
#end
import haxe.io.Bytes;
import haxe.io.BytesInput;

/**
 * A parser for the .sbs (Sparrow Binary Sprite) format.
 * This format is a binary-optimized version of the Sparrow v2 XML spritesheet,
 * designed for smaller file sizes and faster parsing.
 */
class BinarySparrow
{
	/**
	 * The magic number signature for .sbs files ("SBS1").
	 */
	private static final MAGIC_NUMBER:Int = 0x53425331;

	// Control Byte Flags
	private static final FLAG_ROTATED:Int = 0x01;
	private static final FLAG_HAS_FRAME:Int = 0x02;
	private static final FLAG_SAME_DIM:Int = 0x04;
	private static final FLAG_SAME_FRAME:Int = 0x08;
	private static final FLAG_FLIP_X:Int = 0x10;
	private static final FLAG_FLIP_Y:Int = 0x20;

	// Header Options Flags
	private static final OPT_HAS_EMBEDDED_IMAGE:Int = 0x01;

	#if !macro
	/**
	 * Parses a .sbs file from a `Bytes` object and returns a `FlxAtlasFrames` object.
	 *
	 * @param bytes The raw byte data of the .sbs file.
	 * @param graphic An optional pre-existing graphic to use for the atlas. If provided, it takes
	 *                priority over any image path or embedded blob in the .sbs file.
	 * @return A `FlxAtlasFrames` object containing the parsed sprite sheet, or `null` if parsing fails.
	 */
	public static function parse(bytes:Bytes, ?graphic:FlxGraphic):FlxAtlasFrames
	{
		if (bytes == null)
			return null;

		final input = new BytesInput(bytes);
		input.bigEndian = false; // Use Little-Endian

		// 1. Read Header
		final magic = input.readInt32();
		if (magic != MAGIC_NUMBER)
		{
			trace('Error: Invalid .sbs file format. Magic number mismatch.');
			return null;
		}

		final options = input.readByte();

		// 2. Read Image Block
		var imagePath:String = null;
		var imageBlob:Bytes = null;

		final hasEmbeddedImage = (options & OPT_HAS_EMBEDDED_IMAGE) != 0;
		if (hasEmbeddedImage)
		{
			final blobSize = readUInt32(input);
			imageBlob = input.read(blobSize);
		}
		else
		{
			final pathLength = input.readByte();
			imagePath = input.readString(pathLength);
		}

		var flxGraphic:FlxGraphic = graphic;

		if (flxGraphic == null)
		{
			if (imageBlob != null)
			{
				// Create a unique key for the bitmap cache from the blob data
				final key = 'sbs_blob_${Sha1.encode(imageBlob.toHex())}';
				final bitmapData = BitmapData.fromBytes(imageBlob);
				flxGraphic = FlxG.bitmap.add(bitmapData, false, key);
			}
			else if (imagePath != null)
			{
				flxGraphic = FlxG.bitmap.add('assets/textures/${imagePath}');
			}
		}

		if (flxGraphic == null)
			return null;

		// 3. Read Sprite Table
		final frameCount = input.readUInt16();
		final atlasFrames = new FlxAtlasFrames(flxGraphic);

		var lastWidth:Int = 0;
		var lastHeight:Int = 0;
		var lastFrameWidth:Int = 0;
		var lastFrameHeight:Int = 0;

		for (i in 0...frameCount)
		{
			// --- Read Token ---
			final nameLength = input.readByte();
			final name = input.readString(nameLength);

			final control = input.readByte();

			final x = input.readUInt16();
			final y = input.readUInt16();

			var width:Int, height:Int;
			if ((control & FLAG_SAME_DIM) != 0)
			{
				width = lastWidth;
				height = lastHeight;
			}
			else
			{
				width = input.readUInt16();
				height = input.readUInt16();
				lastWidth = width;
				lastHeight = height;
			}

			var frameX:Int = 0,
				frameY:Int = 0,
				frameWidth:Int = 0,
				frameHeight:Int = 0;
			final hasFrame = (control & FLAG_HAS_FRAME) != 0;

			if (hasFrame)
			{
				frameX = input.readInt16();
				frameY = input.readInt16();

				if ((control & FLAG_SAME_FRAME) != 0)
				{
					frameWidth = lastFrameWidth;
					frameHeight = lastFrameHeight;
				}
				else
				{
					frameWidth = input.readUInt16();
					frameHeight = input.readUInt16();
					lastFrameWidth = frameWidth;
					lastFrameHeight = frameHeight;
				}
			}

			final rotated = (control & FLAG_ROTATED) != 0;
			final flipX = (control & FLAG_FLIP_X) != 0;
			final flipY = (control & FLAG_FLIP_Y) != 0;

			// --- Create FlxFrame ---
			final trimmed = hasFrame;
			final rect = FlxRect.get(x, y, width, height);
			final size = if (trimmed)
			{
				FlxRect.get(frameX, frameY, frameWidth, frameHeight);
			}
			else
			{
				FlxRect.get(0, 0, rect.width, rect.height);
			}

			final angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			final offset = FlxPoint.get(-size.x, -size.y);
			final sourceSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				sourceSize.set(size.height, size.width);

			// Prevents issues caused by adding frames of size 0
			if (rect.width == 0 || rect.height == 0)
			{
				if (!trimmed)
					size.setSize(1, 1);

				final frame = atlasFrames.addEmptyFrame(size);
				frame.name = name;
				frame.offset.copyFrom(offset);
				continue;
			}

			atlasFrames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}

		return atlasFrames;
	}
	#end

	/**
	 * Transforms the SparrowV2 XML to a .sbs format.
	 * @param xml The provided xml data.
	 * @param graphic The optional graphic data to add to the image blob.
	 * @return The transformed data.
	 */
	#if macro
	public static function fromXML(xml:String, ?graphic:Bytes):Bytes
	#else
	public static function fromXML(xml:FlxXmlAsset, ?graphic:FlxGraphic):Bytes
	#end
	{
		final root = #if macro Xml.parse(xml) #else xml.getXml() #end.firstElement();

		if (root == null || root.nodeName != "TextureAtlas")
		{
			trace('Error: Invalid XML format. Expected <TextureAtlas> root element.');
			return null;
		}
		var imagePath:String = root.get("imagePath");
		var imageBlob:Bytes = null;

		if (graphic != null)
		{
			// If a graphic is provided, embed its bitmap data
			#if macro
			imageBlob = graphic;
			#else
			final bitmapData = graphic.bitmap;

			bitmapData.encode(new openfl.geom.Rectangle(0, 0, bitmapData.width, bitmapData.height), new PNGEncoderOptions(), imageBlob);
			#end
			imagePath = null; // Clear imagePath as we are embedding
		}
		else if (imagePath == null)
		{
			trace('Error: No imagePath specified in XML and no graphic provided.');
			return null;
		}
		final output = new haxe.io.BytesOutput();

		output.bigEndian = false;
		// 1. Write Header
		output.writeInt32(MAGIC_NUMBER);
		var options:Int = 0;

		if (imageBlob != null)
		{
			options |= OPT_HAS_EMBEDDED_IMAGE;
		}
		output.writeByte(options);
		// 2. Write Image Block
		if (imageBlob != null)
		{
			writeUInt32(output, imageBlob.length);
			output.writeBytes(imageBlob, 0, imageBlob.length);
		}
		else
		{
			output.writeByte(imagePath.length);
			output.writeString(imagePath);
		}
		// 3. Write Sprite Table
		var count:UInt = 0;
		final subTextures = root.elementsNamed("SubTexture");
        var subTexturesAsArray:Array<Xml> = [];

		for (subTexture in subTextures)
			subTexturesAsArray.push(subTexture);

		count = subTexturesAsArray.length;
		output.writeUInt16(count);
		var lastWidth:Int = 0;
		var lastHeight:Int = 0;
		var lastFrameWidth:Int = 0;
		var lastFrameHeight:Int = 0;

		for (subTexture in subTexturesAsArray)
		{
			final name = subTexture.get("name");
			final x = Std.parseInt(subTexture.get("x"));
			final y = Std.parseInt(subTexture.get("y"));
			final width = Std.parseInt(subTexture.get("width"));
			final height = Std.parseInt(subTexture.get("height"));

			final frameX = Std.parseInt(subTexture.get("frameX") ?? "0");
			final frameY = Std.parseInt(subTexture.get("frameY") ?? "0");
			final frameWidth = Std.parseInt(subTexture.get("frameWidth") ?? Std.string(width));
			final frameHeight = Std.parseInt(subTexture.get("frameHeight") ?? Std.string(height));

			final rotated = (subTexture.get("rotated") == "true");
			final flipX = (subTexture.get("flipX") == "true");
			final flipY = (subTexture.get("flipY") == "true");

			// --- Write Token ---
			output.writeByte(name.length);
			output.writeString(name);
			var control:Int = 0;

			if (rotated)
				control |= FLAG_ROTATED;
			if (frameX != 0 || frameY != 0 || frameWidth != width || frameHeight != height)
				control |= FLAG_HAS_FRAME;
			if (width == lastWidth && height == lastHeight)
				control |= FLAG_SAME_DIM;
			if (frameWidth == lastFrameWidth && frameHeight == lastFrameHeight)
				control |= FLAG_SAME_FRAME;
			if (flipX)
				control |= FLAG_FLIP_X;
			if (flipY)
				control |= FLAG_FLIP_Y;
			output.writeByte(control);
			output.writeUInt16(x);
			output.writeUInt16(y);
			if ((control & FLAG_SAME_DIM) == 0)
			{
				output.writeUInt16(width);
				output.writeUInt16(height);
				lastWidth = width;
				lastHeight = height;
			}
			if ((control & FLAG_HAS_FRAME) != 0)
			{
				output.writeInt16(frameX);
				output.writeInt16(frameY);
				if ((control & FLAG_SAME_FRAME) == 0)
				{
					output.writeUInt16(frameWidth);
					output.writeUInt16(frameHeight);
					lastFrameWidth = frameWidth;
					lastFrameHeight = frameHeight;
				}
			}
		}
		return output.getBytes();
	}

	/**
		* Reads a 32-bit unsigned integer from a `BytesInput` in little-endian format.

		* @param input The `BytesInput` to read from.
		* @return The unsigned 32-bit integer value.
	 */
	private static function readUInt32(input:BytesInput):Int
	{
		final b1 = input.readByte();
		final b2 = input.readByte();
		final b3 = input.readByte();
		final b4 = input.readByte();
		return b1 | (b2 << 8) | (b3 << 16) | (b4 << 24);
	}

	/**
	 * Writes a 32-bit unsigned integer to a `BytesOutput` in little-endian format.
	 * @param output The `BytesOutput` to write to.
	 * @param value The unsigned 32-bit integer value to write.
	 */
	private static function writeUInt32(output:haxe.io.BytesOutput, value:Int):Void
	{
		output.writeByte(value & 0xFF);
		output.writeByte((value >>> 8) & 0xFF);
		output.writeByte((value >>> 16) & 0xFF);
		output.writeByte((value >>> 24) & 0xFF);
	}
}
