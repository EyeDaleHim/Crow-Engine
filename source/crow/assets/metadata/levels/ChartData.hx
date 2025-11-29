package crow.assets.metadata.levels;

import crow.assets.metadata.levels.NoteData;

/**
 * The raw data of a gameplay chart.
 */
typedef ChartData =
{
	/**
	 * The base scroll speed for this specific chart.
	 */
	var scrollSpeed:Float;

	/**
	 * The scene file to load for this chart.
	 * If defined, overrides the LevelData's scene.
	 */
	var ?scene:String;

	/**
	 * The list of notes in the chart.
	 */
	var notes:Array<NoteData>;

	/**
	 * Chart-specific events (BPM changes, camera pans, etc).
	 */
	var ?events:Array<Dynamic>;

	/**
	 * Logic-specific metadata for this chart (e.g., custom scripts).
	 */
	var ?meta:Dynamic;
};