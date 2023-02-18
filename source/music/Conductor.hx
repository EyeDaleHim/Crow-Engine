package music;

import flixel.math.FlxMath;
import music.Song;

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000);
	public static var stepCrochet:Float = crochet / 4;

	public static var lastSongPos:Float = 0;
	public static var offset:Float = 0;

	public static var songPosition:Float = 0;

	// until i make bpm changes better, use this
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function mapBPMChanges(song:Song.SongInfo)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.bpmMapping.length)
		{
			curBPM = song.bpmMapping[i].bpm;

			var event:BPMChangeEvent = {
				stepTime: totalSteps,
				songTime: totalPos,
				bpm: curBPM
			};
			bpmChangeMap.push(event);

			totalSteps += song.bpmMapping[i].step;
			totalPos += ((60 / curBPM) * 1000 / 4) * totalSteps;
		}
	}

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
