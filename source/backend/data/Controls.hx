package backend.data;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import backend.data.Settings;
import haxe.ds.StringMap;

class Controls
{
	// does nothing lmao
	public static var instance(get, never):Controls;

	static function get_instance():Controls
	{
		return cast(FlxG.state, MusicBeatState).controls;
	}

	public function new() {}

	public static var RENAME_CONTROLS:StringMap<String> = [
		'NOTE_LEFT' => 'Left Note', 'NOTE_DOWN' => 'Down Note', 'NOTE_UP' => 'Up Note', 'NOTE_RIGHT' => 'Right Note', 'UI_LEFT' => 'Left UI',
		'UI_DOWN' => 'Down UI', 'UI_UP' => 'Up UI', 'UI_RIGHT' => 'Right UI', 'ACCEPT' => 'Accept', 'BACK' => 'Back', 'PAUSE' => 'Pause', 'RESET' => 'Pause'
	];

	// simplify controls to make this much easier
	// not recommended to get the controls directly here unless you're smart
	public var LIST_CONTROLS:Map<String, Control> = [
		'NOTE_LEFT' => new Control(Settings.grabKey('NOTE_LEFT', [FlxKey.A, FlxKey.LEFT]), 0),
		'NOTE_DOWN' => new Control(Settings.grabKey('NOTE_DOWN', [FlxKey.S, FlxKey.DOWN]), 1),
		'NOTE_UP' => new Control(Settings.grabKey('NOTE_UP', [FlxKey.W, FlxKey.UP]), 2),
		'NOTE_RIGHT' => new Control(Settings.grabKey('NOTE_RIGHT', [FlxKey.D, FlxKey.RIGHT]), 3),
		'UI_LEFT' => new Control(Settings.grabKey('UI_LEFT', [FlxKey.A, FlxKey.LEFT]), 4),
		'UI_DOWN' => new Control(Settings.grabKey('UI_DOWN', [FlxKey.S, FlxKey.DOWN]), 5),
		'UI_UP' => new Control(Settings.grabKey('UI_UP', [FlxKey.W, FlxKey.UP]), 6),
		'UI_RIGHT' => new Control(Settings.grabKey('UI_RIGHT', [FlxKey.D, FlxKey.RIGHT]), 7),
		'ACCEPT' => new Control(Settings.grabKey('ACCEPT', [FlxKey.ENTER]), 8),
		'BACK' => new Control(Settings.grabKey('BACK', [FlxKey.ESCAPE, FlxKey.BACKSPACE]), 9),
		'PAUSE' => new Control(Settings.grabKey('PAUSE', [FlxKey.ENTER, FlxKey.BACKSPACE]), 10),
		'RESET' => new Control(Settings.grabKey('RESET', [FlxKey.R]), 11)
	];

	public function getKey(key:String, state:State):Bool
	{
		key = key.toUpperCase();

		if (!LIST_CONTROLS.exists(key))
			return false;

		var fromKey:Control = LIST_CONTROLS[key];

		return switch (state)
		{
			case PRESSED: fromKey.pressed();
			case JUST_PRESSED: fromKey.justPressed();
			case RELEASED: fromKey.released();
			case JUST_RELEASED: fromKey.justReleased();
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
