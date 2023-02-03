package utils;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import openfl.Assets;

class CacheManager
{
	// also they get cached immediately when the game starts, no need to load them when they get used
	// first time
	public static var persistentAssets:Array<String> = ['alphabet', 'mainBG', 'freeplayBG', 'flickerBG'];

	// permaneant cache thing, useful for a "caching-ahead" situation
	public static var cachedAssets:Map<AssetTypeData, Map<String, CachedAsset>> = [
		BITMAP => new Map<String, CachedAsset>(),
		AUDIO => new Map<String, CachedAsset>(),
		DYNAMIC => new Map<String, CachedAsset>()
	];

	public static function getBitmap(key:String = ''):FlxGraphic
	{
		if (FlxG.bitmap.checkCache(key))
			return FlxG.bitmap.get(key);
		else if (cachedAssets[BITMAP].exists(key))
			return cachedAssets[BITMAP].get(key).data;

		return null;
	}

	// threading is useful if you're making dynamic scenes or some WEIRD shit!
	public static function setBitmap(key:String = '', thread:Bool = false):FlxGraphic
	{
		if (Assets.exists(key, IMAGE))
		{
			var graphic:FlxGraphic = FlxGraphic.fromAssetKey(key, false, null, false);
			graphic.persist = true;

			cachedAssets[BITMAP].set(key, {type: BITMAP, data: graphic});

			return getBitmap(key);
		}
		trace('Could not find $key, check your path.');
		return null;
	}

	public static function clearBitmap(graphicKey:String)
	{
		if (cachedAssets[BITMAP].exists(graphicKey))
		{
			FlxG.bitmap.removeByKey(graphicKey);
			cachedAssets[BITMAP].remove(graphicKey);
		}
	}
}

typedef CachedAsset =
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
