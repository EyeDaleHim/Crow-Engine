package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static var defaultFont = Paths.font("vcr.ttf");

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)// :FlxGraphic
	{
		/*
		// reason why we're casting it is to avoid any potential compiler fails that it isn't BitmapData
		var getImage:BitmapData = cast(AssetManager.getAsset('${key}-$library', 'images').trackedAsset, BitmapData);
		if (getImage != null)
		{
			return FlxGraphic.fromBitmapData(getImage, false, null, false);
		}
		// this is extraordinarily long
		var returnImage:BitmapData = AssetManager.setAsset('$key-$library', 'images', BitmapData.fromFile(getPath('images/$key.png', IMAGE, library)))
			.trackedAsset;
		return FlxGraphic.fromBitmapData(returnImage, false, null, false);*/

		return getPath('images/$key.png', IMAGE, library);
	}

	public static function setAsset(key:String, type:String, ?library:String)
	{
		var path = getPath('images/$key.png', IMAGE, library);
	}

	public static var scriptEnds:Array<String> = ['haxe', 'hxc', 'hscript', 'hxscript', 'haxescript'];

	inline static public function hscript(key:String, ?library:String)
	{
		for (file in scriptEnds)
		{
			var path:String = getPath('scripts/$key.$file', TEXT, library);

			if (OpenFlAssets.exists(path, TEXT))
				return path;
		}

		return getPath('scripts/$key.hx', TEXT, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('music/$key.mp4', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(getPath('images/$key.png', IMAGE, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(getPath('images/$key.png', IMAGE, library), file('images/$key.txt', library));
	}
}

class AssetManager
{
	public static var cachedAssets:Map<String, Map<String, CachedAsset>>;
	public static var init(default, set):Bool = false; // unsettable to true after
	public static var allowCaching:Bool = true;

	public static function initAssetManager():Void
	{
		if (!init)
		{
			init = true;
			cachedAssets = [];
			// parsed is basically whatever data like chart data or smth
			for (type in ['images', 'sounds', 'text', 'parsed', 'packer', 'sparrow'])
			{
				cachedAssets.set(type, new Map<String, CachedAsset>());
			}
		}
	}

	public static function getAsset(name:String, type:String):CachedAsset
	{
		initAssetManager();

		if (!allowCaching)
			return null;

		if (cachedAssets.exists(type))
		{
			if (cachedAssets[type].exists(name))
				return cachedAssets[type].get(name).trackedAsset;

			return null;
		}
		trace('Asset Type $type does not exist!');
		return null;
	}

	public static function setAsset(name:String, type:String, asset:Dynamic):CachedAsset
	{
		initAssetManager();

		if (!allowCaching)
			return null;

		if (cachedAssets.exists(type))
		{
			cachedAssets[type].set(name, new CachedAsset(asset));
			return cachedAssets[type].get(name).trackedAsset; // unless you're planning to get the asset directly after setting it
		}
		trace('Asset Type $type does not exist!');
		return null;
	}

	static function set_init(value:Bool):Bool
	{
		if (init)
			return value;

		init = value;
		return value;
	}
}

class CachedAsset // max duration to stay in cache is 180 seconds
{
	public var timeSinceLastUse:Int = 0;
	public var persistent:Bool;
	public var trackedAsset:Dynamic;

	public function new(trackedAsset:Dynamic)
	{
		this.trackedAsset = trackedAsset;
	}
}
