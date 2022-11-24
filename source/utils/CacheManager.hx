package utils;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;

class CacheManager
{
	// also they get cached immediately when the game starts, no need to load them when they get used
	// first time
	public static var persistentAssets:Array<String> = ['alphabet', 'mainBG', 'freeplayBG', 'flickerBG'];

	// permaneant cache thing, useful for a "caching-ahead" situation
	public static var cachedAssets:Map<AssetTypeData, Map<String, AssetCached>> = [
		BITMAP => new Map<String, AssetCached>(),
		AUDIO => new Map<String, AssetCached>(),
		DYNAMIC => new Map<String, AssetCached>()
	];

	public static function getBitmap(key:String = ''):FlxGraphic
	{
		if (FlxG.bitmap.checkCache(key))
			return FlxG.bitmap.get(key);
		else if (cachedAssets[BITMAP].exists(key))
			return cachedAssets[BITMAP].get(key).data;

		return null;
	}

	public static function setBitmap(key:String = ''):FlxGraphic
	{
		var graphic:FlxGraphic = FlxGraphic.fromAssetKey(key, false, null, false);

		cachedAssets[BITMAP].set(key, {type: BITMAP, data: graphic});

		return getBitmap(key);
	}

	public static function clearBitmap(graphicKey:String)
	{
		// for (key in )
	}
}

typedef AssetCached =
{
	var type:AssetTypeData;
	var data:Dynamic;
}

@:enum abstract AssetTypeData(Int)
{
	var BITMAP:AssetTypeData = 0x00;
	var AUDIO:AssetTypeData = 0x01;
	var DYNAMIC:AssetTypeData = 0x10;
}
