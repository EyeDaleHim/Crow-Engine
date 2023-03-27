package weeks;

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

		if (_save.data.savedScores != null)
			songScores = _save.data.savedScores;
		else
			_save.data.savedScores = new Map<String, Map<Int, SongScore>>();

		if (_save.data.weekScores != null)
			weekScores = _save.data.weekScores;
		else
			_save.data.weekScores = new Map<String, Map<Int, SongScore>>();

		FlxG.stage.application.onExit.add(function(_)
		{
			_save.flush();
		});
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

	// set the song results, if the score result is higher than current
	public static function setSong(song:String, diff:Int, result:SongScore):SongScore
	{
		var songScore = songScores.get(song);

		if (songScore == null)
		{
			songScore = new Map<Int, SongScore>();
			songScores.set(song, songScore);
		}

		var currentSongScore = songScore.get(diff);
		var currentPerformance = currentSongScore != null ? currentSongScore.score * currentSongScore.accuracy : -1;
		var newPerformance = result.score * result.accuracy;

		if (newPerformance > currentPerformance)
		{
			songScore.set(diff, result);
			_save.flush();
		}

		return result;
	}

	public static function getWeek(week:String, diff:Int):WeekScore
	{
		if (weekScores.exists(week))
		{
			if (weekScores[week].exists(diff))
				return weekScores[week][diff];
		}

		return {addedScore: 0, averageAccuracy: 0.00, addedMisses: 0};
	}

	public static function setWeek(week:String, diff:Int, results:Array<SongScore>):WeekScore
	{
		var weekScoresValue = weekScores.get(week);
		if (weekScoresValue == null)
		{
			weekScoresValue = new Map<Int, WeekScore>();
			weekScores.set(week, weekScoresValue);
		}
		var weekResult = {addedScore: 0, averageAccuracy: 0.0, addedMisses: 0};
		for (result in results)
		{
			weekResult.addedScore += result.score;
			weekResult.averageAccuracy += result.accuracy;
			weekResult.addedMisses += result.misses;
		}
		weekResult.averageAccuracy /= results.length;
		var diffValue = weekScoresValue.get(diff);
		if (diffValue == null || weekResult.addedScore > diffValue.addedScore)
		{
			weekScoresValue.set(diff, weekResult);
			_save.flush();
		}
		return getWeek(week, diff);
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
