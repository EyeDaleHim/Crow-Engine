package objects.debug;

import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;

// made this class because i do not want to fucking use the same note class ok
class NoteChart extends FlxSprite
{
	public static var UNKNOWN_IMAGE:BitmapData;
	static var SIZE:Int = 16;

	private var _strumTime:Float = 0.0;
	private var _direction:Int = 0;
	private var _noteType(default, set):String = '';
	private var _singAnim:String = '';
	private var _mustPress:Bool = false;
	private var _sustain:Float = 0.0;

	public function new(x:Float = 0.0, y:Float = 0.0, info:ChartNoteInfo)
	{
		super(x, y);

		_strumTime = info.s;
		_direction = info.d;
		_singAnim = info.sA;
		_mustPress = info.mP;
		set__noteType(info.nT);
	}

	// set its skin or something, if notetype's skin is unknown, set this thing's graphic to an unknown
	function set__noteType(string:String)
	{
		return (_noteType = string);
	}
}

typedef ChartNoteInfo =
{
	var s:Float;
	var d:Int;
	var mP:Bool;
	var nT:String;
	var sA:String;
}
