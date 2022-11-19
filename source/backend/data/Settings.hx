package backend.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxSave;

class Settings
{
	public static var prefs:Map<String, Dynamic> = [];
	public static var onSet:Map<String, Dynamic->Void> = [];

	private static var _save:FlxSave;

	public static function init():Void
	{
		_save = new FlxSave();
		_save.bind('settings', 'crow-engine');

		if (_save.data.settings == null)
			_save.data.settings = new Map<String, Dynamic>();

		prefs = cast(_save.data.settings, Map<String, Dynamic>);

		onSet.set('framerate', function(value:Dynamic)
		{
			FlxG.drawFramerate = FlxG.updateFramerate = Std.int(FlxMath.bound(value, 60, 240));
		});

		onSet.set('antialiasing', function(value:Dynamic)
		{
			if (Std.isOfType(value, Bool))
				FlxSprite.defaultAntialiasing = value;
			else
				FlxSprite.defaultAntialiasing = true;
		});

		FlxG.stage.application.onExit.add(function(_)
		{
			_save.close();
		});
	}

	public static function grabKey(name:String, defaultKeys:Array<Int>):Array<Int>
	{
		var keyList = getPref('control-bind', new Map<String, Array<Int>>());

		if (!keyList.exists(name))
			return defaultKeys;

		return keyList.get(name);
	}

	public static function getPref(name:String, ?defaultPref:Dynamic):Dynamic
	{
		return !prefs.exists(name) ? defaultPref : prefs.get(name);
	}

	public static function prefExists(name:String):Bool
	{
		return prefs.exists(name);
	}

	public static function setPref(name:String, value:Dynamic):Dynamic
	{
		prefs.set(name, value);
		if (onSet.exists(name))
			onSet.get(name)(value);
		return getPref(name);
	}
}
