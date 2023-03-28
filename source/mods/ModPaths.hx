package mods;

import openfl.Assets;

#if MODS_ENABLED
class ModPaths
{
	public static var currentMod:String = "";

	public static function getPath(mod:String, path:String, types:Array<String>):String
	{
		var realPath:String = 'mods/$mod/$path';

		if (types != null || types.length > 0)
		{
			for (type in types)
			{
				realPath = '$realPath.$type';
				if (Assets.exists(realPath))
					break;
			}
		}

		return realPath;
	}

	public static function getPathAsFolder(mod:String, folder:String):String
	{
		return 'mods/$mod/$folder';
	}

	public static function data(mod:String, path:String):String
	{
		return getPath(mod, 'data/$path', []);
	}

	public static function image(mod:String, path:String):String
	{
		return getPath(mod, 'images/$path', ['png']);
	}

	public static function music(mod:String, path:String):String
	{
		return getPath(mod, 'music/$path', ['wav', 'mp3', 'ogg']);
	}

	public static function sound(mod:String, path:String):String
	{
		return getPath(mod, 'sounds/$path', ['wav', 'mp3', 'ogg']);
	}

	public static function chart(mod:String, song:String, diff:String):String
	{
		return getPath(mod, 'data/charts/$song/$song-${diff.length > 0 ? '$diff' : ''}', ['json']);
	}

	public static function script(mod:String, script:String, context:String):String
	{
		return getPath(mod, 'scripts/$context/$script', ['hscript', 'hxs', 'hx']);
	}
}
#else
class ModPaths
{
	public static function getPath(mod:String, path:String, types:Array<String>):Null<String>
	{
		return null;
	}

	public static function image(mod:String, path:String):Null<String>
	{
		return null;
	}

	public static function music(mod:String, path:String):Null<String>
	{
		return null;
	}

	public static function sound(mod:String, path:String):Null<String>
	{
		return null;
	}

	public static function chart(mod:String, song:String, diff:String):Null<String>
	{
		return null;
	}

	public static function script(mod:String, script:String, context:String):Null<String>
	{
		return null;
	}
}
#end
