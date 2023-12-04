package backend;

import flixel.input.keyboard.FlxKey;
import backend.data.Controls;
import openfl.events.KeyboardEvent;

class InputHandler
{
	private static var _isInit:Bool = false;

	private static var keyMapping:Map<Int, Array<KeyFunction>>;

	public static function init():Void
	{
		if (_isInit)
			return;

		_isInit = true;

		keyMapping = new Map<Int, Array<KeyFunction>>();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent)
		{
			if (keyMapping.exists(e.keyCode))
			{
				var keyMap:Array<KeyFunction> = keyMapping.get(e.keyCode);

				for (i in 0...keyMap.length)
				{
					if (keyMap[i].KEY_DOWN != null)
						keyMap[i].KEY_DOWN();
				}
			}
		});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent)
		{
			if (keyMapping.exists(e.keyCode))
			{
				var keyMap:Array<KeyFunction> = keyMapping.get(e.keyCode);

				for (i in 0...keyMap.length)
				{
					if (keyMap[i].KEY_UP != null)
						keyMap[i].KEY_UP();
				}
			}
		});
	}

	public static function registerControl(control:String, ?keyDown:() -> Void = null, ?keyUp:() -> Void = null):Void
	{
        if (!_isInit)
            return;

        if (Controls.instance.LIST_CONTROLS.exists(control))
        {
            @:privateAccess
            registerKeys(Controls.instance.LIST_CONTROLS.get(control).__keys, keyDown, keyUp);
        }
	}

	public static function registerKeys(keys:Array<Int>, ?keyDown:() -> Void = null, ?keyUp:() -> Void = null):Void
	{
		if (!_isInit && keys != null)
			return;

		for (key in keys)
		{
			if (!keyMapping.exists(key))
				keyMapping.set(key, []);

			keyMapping.get(key).push({KEY_DOWN: keyDown, KEY_UP: keyUp});
		}
	}

	public static function clearInputs():Void
	{
		if (!_isInit)
			return;

		keyMapping.clear();
	}
}

typedef KeyFunction =
{
	@:optional var KEY_DOWN:() -> Void;
	@:optional var KEY_UP:() -> Void;
}
