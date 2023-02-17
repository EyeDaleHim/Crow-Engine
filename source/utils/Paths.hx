package utils;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flash.media.Sound;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import utils.CacheManager;
import utils.CacheManager.AssetTypeData;

using StringTools;
using utils.Tools;

class Paths
{
	inline static public var SOUND_EXT:String = #if web 'mp3' #else 'ogg' #end;

	// List of libraries
	private static var hasInit:Bool = false;

	public static var currentLibrary:String = '';

	public static function init()
	{
		if (hasInit)
			return;

		hasInit = true;
	}

	// format manifesting
	private static function resolveManifest(file:String = '', ?library:String = null):String
	{
		var middle:String = '-';

		if (library == null || (library != null && library == ''))
		{
			library = '';
			middle = '';
		}

		if (file == null)
			file = '';

		return library + middle + file;
	}

	// format paths
	private static function formatPath(file:String, library:Null<String>)
	{
		if (library != null && library != '')
			return '${library}:assets/${library}/${file}';
		return 'assets/${file}';
	}

	private static function extensionHelper(name:String)
	{
		if (name.split('.')[2] != null)
			return name.split('.')[0] + '.' + name.split('.')[1];

		return name;
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLibrary != null)
		{
			var levelPath = getLibraryPathForce(file, currentLibrary);
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

	public static function image(file:String, ?library:String = null):FlxGraphic
	{
		var fullPath:String = imagePath(file, library);

		if (CacheManager.cachedAssets[BITMAP].exists(fullPath))
			return CacheManager.getBitmap(fullPath);

		return CacheManager.setBitmap(fullPath);
	}

	public inline static function imagePath(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('images/${file}.png'), IMAGE, library);
	}

	public inline static function sound(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('sounds/${file}.$SOUND_EXT'), SOUND, library);
	}

	public static function inst(song:String):Sound
	{
		var fullPath:String = instPath(song);

		if (CacheManager.cachedAssets[AUDIO].exists(fullPath))
			return CacheManager.getAudio(fullPath);

		return CacheManager.setAudio(fullPath);
	}

	public static function instPath(song:String):String
	{
		return music('songs/${song.toLowerCase().replace(' ', '-')}/Inst');
	}

	public static function vocals(song:String):Sound
	{
		var fullPath:String = vocalsPath(song);

		if (CacheManager.cachedAssets[AUDIO].exists(fullPath))
			return CacheManager.getAudio(fullPath);

		return CacheManager.setAudio(fullPath);
	}

	public static function vocalsPath(song:String):String
	{
		return music('songs/${song.toLowerCase().replace(' ', '-')}/Voices');
	}

	public static function music(song:String, ?library:String = null):String
	{
		return getPreloadPath(extensionHelper('music/${song}.$SOUND_EXT'));
	}

	public static function font(file:String):String
	{
		return getPath(extensionHelper('fonts/${file}.ttf'), FONT, null);
	}

	public static function data(file:String):String
	{
		return getPreloadPath(extensionHelper('data/${file}.json'));
	}

	public static function file(file:String, end:String, type:AssetType, ?library:String = null):String
	{
		return getPath('$file.$end', type, library);
	}

	public static function getSparrowAtlas(file:String, ?library:String = null):FlxAtlasFrames
	{
		var xmlPath:String = Paths.imagePath(file, library).replace('png', 'xml');
		return FlxAtlasFrames.fromSparrow(Paths.image(file, library), OpenFlAssets.getText(xmlPath));
	}

	public static function getPackerAtlas(file:String, ?library:String = null):FlxAtlasFrames
	{
		var txtPath:String = Paths.imagePath(file, library).replace('png', 'txt');
		return FlxAtlasFrames.fromSpriteSheetPacker(Paths.image(file, library), OpenFlAssets.getText(txtPath));
	}
}
