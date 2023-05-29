package backend.graphic;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import sys.io.File;
import flash.media.Sound;
import openfl.Assets;
import openfl.display.BitmapData;
import haxe.ds.StringMap;
import openfl.utils.ByteArray;
import haxe.io.Bytes;

class CacheManager
{
	// also they get cached immediately when the game starts, no need to load them when they get used
	// first time
	public static var persistentAssets:Array<String> = [
		'assets/images/alphabet.png',
		'assets/images/menus/mainBG.png',
		'assets/images/menus/freeplayBG.png',
		'assets/images/menus/flickerBG.png',
		'assets/images/menus/settingsBG.png',
		'assets/images/loading.png'
	];

	// permaneant cache thing, useful for a "caching-ahead" situation
	public static var cachedAssets:Map<AssetTypeData, StringMap<CachedAsset>> = [
		BITMAP => new Map<String, CachedAsset>(),
		AUDIO => new Map<String, CachedAsset>(),
		XML => new Map<String, CachedAsset>(),
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
		var modsEnabled:Bool = #if MODS_ENABLED FileSystem.exists(key) #else false #end;

		if (modsEnabled || Assets.exists(key, IMAGE))
		{
			var graphic:FlxGraphic = null;
			if (modsEnabled)
			{
				var bitmap:BitmapData = #if !sys
				BitmapData.fromFile(key) 
				#else
				BitmapData.fromBytes(ByteArray.fromBytes(sys.io.File.getBytes(key)))
				#end;
				graphic = FlxGraphic.fromBitmapData(bitmap, false, key);
			}
			else if (graphic == null)
				graphic = FlxGraphic.fromAssetKey(key, false, null, false);
			graphic.persist = true;

			FlxG.bitmap.addGraphic(graphic);
			cachedAssets[BITMAP].set(key, {type: BITMAP, data: FlxG.bitmap.get(graphic.key)});

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
		else
			trace('Couldn\'t find $graphicKey to remove its cache.');
	}

	public static function getAudio(key:String = ''):Sound
	{
		if (cachedAssets[AUDIO].exists(key))
			return cachedAssets[AUDIO].get(key).data;

		return null;
	}

	public static function setAudio(key:String = '', thread:Bool = false):Sound
	{
		if (#if MODS_ENABLED FileSystem.exists(key) || #end Assets.exists(key, SOUND))
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

	public static function getDynamic(dynamicKey:String):Dynamic
	{
		if (cachedAssets[DYNAMIC].exists(dynamicKey))
			return cachedAssets[DYNAMIC].get(dynamicKey);
		return null;
	}

	public static function setDynamic(dynamicKey:String, data:Dynamic):Dynamic
	{
		if (getDynamic(dynamicKey) == null)
			cachedAssets[DYNAMIC].set(dynamicKey, data);

		return getDynamic(dynamicKey);
	}

	public static function clearDynamic(dynamicKey:String, ?destroyFunction:Void->Void)
	{
		if (cachedAssets[DYNAMIC].exists(dynamicKey))
		{
			if (destroyFunction != null)
				destroyFunction();
			cachedAssets[DYNAMIC].remove(dynamicKey);
		}
	}

	public static function freeMemory(type:AssetTypeData = DYNAMIC, keepPersistence:Bool = true):Void
	{
		for (cache in cachedAssets[type].keys())
		{
			if (keepPersistence && persistentAssets.contains(cache))
				continue;

			switch (type)
			{
				case AUDIO:
					{
						clearAudio(cache);
					}
				case BITMAP:
					{
						clearBitmap(cache);
					}
				case DYNAMIC:
					{
						clearDynamic(cache);
					}
				case _:
			}
		}
	}
}

typedef CachedAsset =
{
	@:optional var special:Bool; // even "freeMemory" won't work, you'd have to define this "false" to wipe it
	var type:AssetTypeData;
	var data:Dynamic;
}

enum abstract AssetTypeData(Int)
{
	var BITMAP:AssetTypeData = 0;
	var AUDIO:AssetTypeData = 1;
	var XML:AssetTypeData = 2;
	var DYNAMIC:AssetTypeData = 3;
	var ANY:AssetTypeData = -1;
}
