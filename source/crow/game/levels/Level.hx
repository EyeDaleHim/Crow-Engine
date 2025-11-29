package crow.game.levels;

import crow.assets.metadata.levels.LevelData;
import crow.assets.metadata.levels.ChartData;
import crow.assets.metadata.helpers.TranslatableString;
import haxe.io.Path;

/**
 * A runtime representation of a single playable unit (a specific chart/audio combo).
 */
class Level
{
	/**
	 * The unique ID.
	 */
	public var id(default, null):String;

	/**
	 * The raw metadata.
	 */
	public var data(default, null):LevelData;

	/**
	 * The loaded chart data. Null until `loadChart()` is called.
	 */
	public var chart(default, null):ChartData;

	/**
	 * The display name (e.g. "Hard", "Normal").
	 */
	public var title:TranslatableString;

	public function new(data:LevelData)
	{
		this.data = data;
		this.id = data.id;
		this.title = data.displayName ?? "unknown";
	}

	/**
	 * Loads the chart data from assets.
	 * @return True if successful.
	 */
	public function loadChart():Bool
	{
		if (data.chartPath == null)
			return false;

		try
		{
			// Assuming charts are stored relative to an assets folder
			// or the path in metadata is full relative path from assets root.
			this.chart = Main.assets.json(data.chartPath);
			return this.chart != null;
		}
		catch (e:Dynamic)
		{
			trace('Level: Failed to load chart for $id at ${data.chartPath}: $e');
			return false;
		}
	}

	public function getAudioPaths():LevelAudioData
	{
		return data.audio;
	}
}
