package backend.data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxSave;

class Settings
{
	public static var prefs:Map<String, Dynamic> = [];
	public static var controls:Map<String, Array<Int>> = [];
	public static var onSet:Map<String, Dynamic->Void> = [];

	private static var _save:FlxSave;

	public static function init():Void
	{
		_save = new FlxSave();
		_save.bind('settings', 'crow-engine');

		prefs = _save.data.settings ?? new Map<String, Dynamic>();
		controls = _save.data.controls ?? new Map<String, Dynamic>();

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

		onSet['framerate'](getPref('framerate', 60));
		onSet['antialiasing'](getPref('antialiasing', true));

		FlxG.stage.application.onExit.add(function(_)
		{
			_save.data.controls = controls;
			_save.flush();
		});
	}

	public static function grabKey(name:String, ?defaultKeys:Array<Int>):Array<Int>
	{
		if (controls != null && !controls.exists(name))
			return defaultKeys;

		return controls.get(name);
	}

	public static function changeKey(name:String, keys:Array<Int>):Array<Int>
	{
		controls.set(name, keys);

		return grabKey(name);
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
