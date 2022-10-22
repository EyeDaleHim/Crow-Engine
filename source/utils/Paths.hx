package utils;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline static public var SOUND_EXT:String = #if web 'mp3' #else 'ogg' #end;

	// List of libraries
	public static var libraries:Array<String> = ['week1', 'week2', 'week3', 'week4', 'week5', 'week6'];

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

	public static function getPath(file:String = '', type:AssetType, ?library:String = null):String
	{
		var preload:String = getPreloadPath(file);

		if (library == null)
		{
			if (OpenFlAssets.exists(preload, type))
			{
				return preload;
			}
			else
			{
				for (libFolder in libraries)
				{
					var folder:String = getPath(file, type, libFolder);
					if (OpenFlAssets.exists(folder, type))
					{
						return formatPath(file, libFolder);
					}
					trace('couldn\'t find $folder');
				}
			}
		}

		if (currentLibrary != null)
			return getPath(file, type, currentLibrary);
		else
			return getPreloadPath(file);
	}

	public static function getPreloadPath(file:String = ''):String
	{
		return formatPath(file, '');
	}

	public static function image(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('images/${file}.png'), IMAGE, library);
	}

	public static function sound(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('sounds/${file}.$SOUND_EXT'), SOUND, library);
	}

	public static function inst(song:String, ?library:String = null):String
	{
		return getPath(extensionHelper('data/${song}/Inst.$SOUND_EXT'), SOUND, library);
	}

	public static function vocals(song:String, ?library:String = null):String
	{
		return getPath(extensionHelper('data/${song}/Voice.$SOUND_EXT'), SOUND, library);
	}

	public static function music(song:String):String
	{
		return getPreloadPath(extensionHelper('music/${song}.$SOUND_EXT'));
	}

	public static function font(file:String):String
	{
		return getPath(extensionHelper('fonts/${file}.ttf'), FONT);
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
		return FlxAtlasFrames.fromSparrow(image(file), OpenFlAssets.getText(Paths.file('images/$file', 'xml', TEXT, library)));
	}
}
