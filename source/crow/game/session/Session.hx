package crow.game.session;

import crow.game.levels.Level;
import crow.game.levels.Playlist;
import crow.assets.metadata.levels.GameStemData;

class Session
{
	public var currentLevel:Level;
	public var playlist:Playlist;
	public var playlistIndex:Int;

	/**
	 * The metric for the current level.
	 * 
	 * They will reset upon the next level if on a playlist.
	 */
	public var currentMetric:SessionMetric;

	/**
	 * The metric for the campaign.
	 */
	public var campaignMetric:SessionMetric;

	public function new(gameStem:GameStemData)
	{
		if (gameStem.level != null && gameStem.playlist != null)
		{
			throw "Cannot provide both a level and a playlist.";
		}

		if (gameStem.level != null)
		{
			currentLevel = gameStem.level;
		}
		else if (gameStem.playlist != null)
		{
			playlist = gameStem.playlist;
			playlistIndex = 0;
			currentLevel = playlist.queue[playlistIndex];
		}
		else
		{
			throw "Must provide either a level or a playlist.";
		}

		currentMetric = {
			score: 0,
			hits: 0,
			weightedHits: 0.0,
			misses: 0
		};

		campaignMetric = {
			score: 0,
			hits: 0,
			weightedHits: 0.0,
			misses: 0
		};
	}

	public function hasNext():Bool
	{
		if (playlist != null)
		{
			return playlistIndex + 1 < playlist.queue.length;
		}
		return false;
	}

	public function next():Void
	{
		campaignMetric.score += currentMetric.score;
		campaignMetric.hits += currentMetric.hits;
		campaignMetric.weightedHits += currentMetric.weightedHits;
		campaignMetric.misses += currentMetric.misses;

		currentMetric = {
			score: 0,
			hits: 0,
			weightedHits: 0.0,
			misses: 0
		};

		if (playlist != null)
		{
			playlistIndex++;
			if (playlistIndex < playlist.queue.length)
			{
				currentLevel = playlist.queue[playlistIndex];
			}
			else
			{
				currentLevel = null; // End of playlist
			}
		}
		else
		{
			currentLevel = null; // No playlist, so no next level
		}
	}
}

typedef SessionMetric =
{
	/**
	 * The total score for the current session.
	 */
	var score:Int;

	/**
	 * The total hits for the current session.
	 */
	var hits:Int;

	/**
	 * The total weighted hits for the current session.
	 */
	var weightedHits:Float;

	/**
	 * The total misses for the current session.
	 */
	var misses:Int;
}
