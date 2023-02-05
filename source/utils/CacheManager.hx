package utils;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flash.media.Sound;
import openfl.Assets;
import haxe.ds.StringMap;

class CacheManager
{
	// also they get cached immediately when the game starts, no need to load them when they get used
	// first time
	public static var persistentAssets:Array<String> = [
		'assets/images/alphabet.png',
		'assets/images/menus/mainBG.png',
		'assets/images/menus/freeplayBG.png',
		'assets/images/menus/flickerBG.png',
		'assets/images/menus/settingsBG.png'
	];

	// permaneant cache thing, useful for a "caching-ahead" situation
	public static var cachedAssets:Map<AssetTypeData, StringMap<CachedAsset>> = [
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

			cast(cachedAssets[BITMAP].get(graphicKey).data, FlxGraphic).destroy();
			cachedAssets[BITMAP].remove(graphicKey);
		}
	}

	public static function getAudio(key:String = ''):Sound
	{
		if (cachedAssets[AUDIO].exists(key))
			return cachedAssets[AUDIO].get(key).data;

		return null;
	}

	public static function setAudio(key:String = '', thread:Bool = false):Sound
	{
		if (Assets.exists(key, SOUND))
		{
			var sound:Sound = Sound.fromFile(key);

			cachedAssets[AUDIO].set(key, {type: AUDIO, data: sound});

			return getAudio(key);
		}
		trace('Could not find $key, check your path.');
		return null;
	}

	public static function clearAudio(audioKey:String)
	{
		if (cachedAssets[AUDIO].exists(audioKey))
		{
			cast(cachedAssets[AUDIO].get(audioKey).data, Sound).close();
			cachedAssets[AUDIO].remove(audioKey);
		}
	}

	public static function freeMemory(type:AssetTypeData = DYNAMIC, keepPersistence:Bool = true):Void
	{
		if (type != DYNAMIC)
		{
			var listOfCache:Int = 0;

			for (cache in cachedAssets[type].keys())
			{
				listOfCache++;

				if (keepPersistence && persistentAssets.contains(cache))
					continue;

				switch (type)
				{
					case AUDIO:
						{
							trace('Cleared out $cache');
							clearAudio(cache);
							listOfCache--;
						}
					case BITMAP:
						{
							trace('Cleared out $cache');
							clearBitmap(cache);
							listOfCache--;
						}
					case _:
				}
			}

			trace('Over ${listOfCache} have been cleared from the cache.');
		}
		else
		{
			for (eachType in cachedAssets)
			{
				for (cache in eachType.keys())
				{
					if (keepPersistence && persistentAssets.contains(cache))
						continue;

					switch (type)
					{
						case AUDIO:
							{
								trace('Cleared out $cache');
								clearAudio(cache);
							}
						case BITMAP:
							{
								trace('Cleared out $cache');
								clearBitmap(cache);
							}
						case _:
					}
				}
			}
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
	var FRAME:AssetTypeData = 0x10;
	var DYNAMIC:AssetTypeData = 0x11;
}
