package backend;

import flixel.FlxG;
import flixel.util.FlxSave;

class ScoreContainer
{
	private static var folder:String = 'base_game';
	private static var _save:FlxSave;

	public static var songScores:Map<String, Map<Int, SongScore>> = [];
	public static var weekScores:Map<String, Map<Int, WeekScore>> = [];

	public static function init():Void
	{
		_save = new FlxSave();
		changeFolder('base-game');
	}

	public static function changeFolder(x:String):Void
	{
		folder = x;
		_save.bind(folder + '-highscore', 'crow-engine');
	}

	// Gets the song info, if one exists
	public static function getSong(song:String, diff:Int):SongScore
	{
		if (songScores.exists(song))
		{
			if (songScores[song].exists(diff))
				return songScores[song][diff];
		}

		return {score: 0, accuracy: 0.00, misses: 0};
	}
}

typedef SongScore =
{
	var score:Int;
	var accuracy:Float;
	var misses:Int;
}

typedef WeekScore =
{
	var addedScore:Int;
	var averageAccuracy:Float;
	var addedMisses:Int;
}
