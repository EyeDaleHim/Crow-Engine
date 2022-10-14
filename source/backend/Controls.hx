package backend;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Controls
{
	// does nothing lmao
	public function new() {}

	// simplify controls to make this much easier
	// not recommended to get the controls directly here unless you're smart
	public var LIST_CONTROLS:Map<String, Control> = [
		'NOTE_LEFT' => new Control([FlxKey.A, FlxKey.LEFT], 0),
		'NOTE_DOWN' => new Control([FlxKey.S, FlxKey.DOWN], 1),
		'NOTE_UP' => new Control([FlxKey.W, FlxKey.UP], 2),
		'NOTE_RIGHT' => new Control([FlxKey.D, FlxKey.RIGHT], 3),
		'UI_LEFT' => new Control([FlxKey.A, FlxKey.LEFT], 4),
		'UI_DOWN' => new Control([FlxKey.S, FlxKey.DOWN], 5),
		'UI_UP' => new Control([FlxKey.W, FlxKey.UP], 6),
		'UI_RIGHT' => new Control([FlxKey.D, FlxKey.RIGHT], 7),
		'ACCEPT' => new Control([FlxKey.ENTER], 8),
		'BACK' => new Control([FlxKey.ESCAPE, FlxKey.BACKSPACE], 9),
		'PAUSE' => new Control([FlxKey.ENTER, FlxKey.BACKSPACE], 10),
		'RESET' => new Control([FlxKey.R], 11)
	];

	public function getKey(key:String, state:State):Bool
	{
		key = key.toUpperCase();

		if (!LIST_CONTROLS.exists(key))
			return false;

		var fromKey:Control = LIST_CONTROLS[key];

		switch (state)
		{
			case PRESSED:
				return fromKey.pressed();
			case JUST_PRESSED:
				return fromKey.justPressed();
			case RELEASED:
				return fromKey.released();
			case JUST_RELEASED:
				return fromKey.justReleased();
		}
	}
}

class Control
{
	private var __keys:Array<Int>;

	public var id:Int = -1;

	public function new(keys:Array<FlxKey>, ID:Int = -1)
	{
		keys.remove(-2);
		keys.remove(-1);

		__keys = keys;

		id = ID;
	}

	public function pressed():Bool
	{
		return FlxG.keys.anyPressed(__keys);
	}

	public function justPressed():Bool
	{
		return FlxG.keys.anyJustPressed(__keys);
	}

	public function released():Bool
	{
		return !FlxG.keys.anyPressed(__keys);
	}

	public function justReleased():Bool
	{
		return FlxG.keys.anyJustReleased(__keys);
	}
}

enum State
{
	PRESSED;
	JUST_PRESSED;
	RELEASED;
	JUST_RELEASED;
}
