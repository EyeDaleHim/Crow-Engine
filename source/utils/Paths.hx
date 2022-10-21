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
	public static var libraries:Array<String> = ['shared', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6', 'week7'];

	private static var hasInit:Bool = false;

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
	private static function formatPath(info:{file:String, library:String})
	{
		if (info.library != null && info.library != '')
			return 'assets/libraries/${info.library}/${info.file}';
		return 'assets/${info.file}';
	}

	private static function extensionHelper(name:String)
	{
		if (name.split('.')[2] != null)
			return name.split('.')[0] + '.' + name.split('.')[1];

		return name;
	}

	public static function getPath(file:String = '', ?library:String = null):String
	{
		var preload:String = getPreloadPath(file);

		if (library == null)
		{
			if (OpenFlAssets.exists(preload, IMAGE))
			{
				return preload;
			}
			else
			{
				for (libFolder in libraries)
				{
					var folder:String = getPath(file, libFolder);
					if (OpenFlAssets.exists(folder))
					{
						if (!manifest.exists(resolveManifest(file, library)))
							manifest.set(resolveManifest(file, library), {file: file, library: library});
						return formatPath(manifest.get(resolveManifest(file, library)));
					}
					trace('couldn\'t find $folder');
				}
			}
		}

		return 'library:$file';
	}

	public static function getPreloadPath(file:String = ''):String
	{
		if (!manifest.exists(resolveManifest(file, '')))
			manifest.set(resolveManifest(file, ''), {file: file, library: ''});

		return formatPath(manifest.get(resolveManifest(file, '')));
	}

	public static function image(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('images/${file}.png'), library);
	}

	public static function sound(file:String, ?library:String = null):String
	{
		return getPath(extensionHelper('sounds/${file}.$SOUND_EXT'), library);
	}

	public static function inst(song:String, ?library:String = null):String
	{
		return getPath(extensionHelper('data/${song}/Inst.$SOUND_EXT'), library);
	}

	public static function vocals(song:String, ?library:String = null):String
	{
		return getPath(extensionHelper('data/${song}/Voice.$SOUND_EXT'), library);
	}

	public static function music(song:String):String
	{
		return getPreloadPath(extensionHelper('music/${song}.$SOUND_EXT'));
	}

	public static function font(file:String):String
	{
		return getPath(extensionHelper('fonts/${file}.ttf'));
	}

	public static function data(file:String):String
	{
		return getPreloadPath(extensionHelper('data/${file}.json'));
	}

	public static function file(file:String, end:String, ?library:String = null):String
	{
		return getPath('$file.$end', library);
	}

	public static function getSparrowAtlas(file:String, ?library:String = null):FlxAtlasFrames
	{
		return FlxAtlasFrames.fromSparrow(image(file), OpenFlAssets.getText(Paths.file('images/$file', 'xml', library)));
	}
}
