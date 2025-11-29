package crow.assets.metadata.levels;

import crow.assets.metadata.helpers.EaseData;
import crow.assets.metadata.levels.NoteData;
import flixel.util.typeLimit.OneOfTwo;

/**
 * The raw data of a gameplay chart.
 */
typedef ChartData =
{
	/**
	 * The scroll speed for this specific chart.
	 * 
	 * Can be a fixed `Float` or a list of `ChartChangeNode`s for automation.
	 */
	var scrollSpeed:OneOfTwo<Float, Array<ChartChangeNode>>;

	/**
	 * The BPM for this specific chart.
	 * 
	 * Can be a fixed `Float` or a list of `ChartChangeNode`s for automation.
	 */
	var bpm:OneOfTwo<Float, Array<ChartChangeNode>>;

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

/**
 * Represents a timed change in a chart value.
 */
typedef ChartChangeNode =
{
	/**
	 * The timestamp of the change in milliseconds.
	 */
	var time:Float;

	/**
	 * The new target value.
	 */
	var value:Float;

	/**
	 * How the value changes to the target.
	 * Default is `CONSTANT` if undefined.
	 */
	var ?type:ChartChangeType;

	/**
	 * The duration of the change in milliseconds.
	 * Required if `type` is `LINEAR` or `TWEEN`.
	 */
	var ?duration:Float;

	/**
	 * The easing name (e.g. "quadOut") if using a tween.
	 */
	var ?ease:EaseData;
};

/**
 * Defines how a chart value transitions to a new target.
 */
enum abstract ChartChangeType(String) to String
{
	/**
	 * Instantly sets the value at the given time.
	 */
	var CONSTANT = "CONSTANT";

	/**
	 * Linearly interpolates to the value over the duration.
	 */
	var LINEAR = "LINEAR";

	/**
	 * Interpolates to the value using a specific easing function over the duration.
	 */
	var TWEEN = "TWEEN";

	@:from
	public static function fromString(value:String):ChartChangeType
	{
		return switch (value?.trim().toUpperCase())
		{
			case "LINEAR": LINEAR;
			case "TWEEN", "EASE": TWEEN;
			case "CONSTANT", "STEP", null: CONSTANT;
			default:
				// Default to CONSTANT for unknown values to prevent crashes
				CONSTANT;
		}
	}
}
