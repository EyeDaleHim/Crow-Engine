package backend;

import flixel.system.FlxAssets;
import openfl.text.Font;

class Assets
{
	public static var graphicCache(get, never):Map<String, FlxGraphic>;
	public static var soundCache:Map<String, Sound> = [];

	public static var fonts:Map<String, Font> = [];

	inline public static function assetPath(path:String):String
	{
		return 'assets/$path';
	}

	inline public static function imagePath(path:String):String
	{
		return 'assets/images/$path.png';
	}

	inline public static function soundPath(path:String, type:Null<SoundType>):String
	{
		var truePath:String = "assets/sounds/";
		if (type != null)
			truePath += type;
		truePath += '/$path';
		truePath += '.${FlxAssets.defaultSoundExtension}';
		return truePath;
	}

	inline public static function musicPath(path:String):String
		return soundPath(path, MUSIC);

	inline public static function sfxPath(path:String):String
		return soundPath(path, SFX);

	inline public static function fontPath(path:String):String
		return assetPath('fonts/$path.ttf');

	public static function readBytes(path:String):Bytes
	{
		if (FileSystem.exists(path))
			return File.getBytes(path);

		return null;
	}

	public static function readText(path:String):String
	{
		if (FileSystem.exists(path))
			return File.getContent(path);

		return "";
	}

	public static function font(path:String):Font
	{
		var font:Font = null;
		var file:String = fontPath(path);

		if (fonts.exists(path))
			font = fonts.get(path);
		else
		{
			fonts.set(path, Font.fromBytes(Assets.readBytes(file)));
			font = Assets.font(path);

			Font.registerFont(font);
		}

		return font;
	}

	public static function image(path:String, hardware:Bool = true):FlxGraphic
	{
		// hardware = Settings.gpu && hardware;

		var bitmap:BitmapData = null;
		var graphic:FlxGraphic = null;
		var file:String = imagePath(path);

		if (graphicCache.exists(file))
			return graphicCache.get(file);
		else if (FileSystem.exists(file))
			bitmap = BitmapData.fromFile(file);

		if (bitmap != null)
		{
			if (hardware)
			{
				@:privateAccess {
					bitmap.lock();
					if (bitmap.__texture == null)
					{
						bitmap.image.premultiplied = true;
						bitmap.getTexture(FlxG.stage.context3D);
					}
					bitmap.getSurface();
					bitmap.disposeImage();
					bitmap.image.data = null;
					bitmap.image = null;
					bitmap.readable = true;
				}
			}

			graphic = FlxGraphic.fromBitmapData(bitmap, false, file);
			graphic.persist = true;
			graphic.destroyOnNoUse = false;

			FlxG.bitmap.addGraphic(graphic);
		}

		return graphic;
	}

	public static function frames(path:String):FlxFramesCollection
	{
		var image:FlxGraphic = image(path);
		var xml:String = readText(imagePath(path).replace('.png', '.xml'));

		var returnedFrames:FlxAtlasFrames = null;

		try
		{
			returnedFrames = FlxAtlasFrames.fromSparrow(image, xml);
		} catch (e)
		{
			trace(e.toString());
			if (xml.length == 0)
				return FlxImageFrame.fromFrame(FlxG.bitmap.whitePixel);
		}

		if (returnedFrames == null)
			return FlxImageFrame.fromFrame(FlxG.bitmap.whitePixel);

		return returnedFrames;
	}

	public static function sound(path:String, type:SoundType):Sound
	{
		var file:String = soundPath(path, type);
		var sound:Sound = null;

		if (soundCache.exists(file))
		{
			return soundCache.get(file);
		}
		else if (FileSystem.exists(file))
		{
			sound = Sound.fromFile(file);

			soundCache.set(file, sound);
		}

		return sound;
	}

	public static function music(path:String):Sound
	{
		return sound(path, MUSIC);
	}

	public static function sfx(path:String):Sound
	{
		return sound(path, SFX);
	}

	static function get_graphicCache():Map<String, FlxGraphic>
	{
		@:privateAccess
		{
			return FlxG.bitmap._cache;
		}
	}
}

enum abstract SoundType(String)
{
	var MUSIC:SoundType = "music";
	var SFX:SoundType = "sfx";
}
