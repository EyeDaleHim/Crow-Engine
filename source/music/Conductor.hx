package music;

import flixel.math.FlxMath;

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000);
	public static var stepCrochet:Float = crochet / 4;

	public static var lastSongPos:Float = 0;
	public static var offset:Float = 0;

	public static var songPosition:Float = 0;

	public static function changeBPM(newBPM:Float = 100.0)
	{
		bpm = newBPM;
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}
