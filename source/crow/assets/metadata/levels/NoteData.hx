package crow.assets.metadata.levels;

/**
 * Represents a single hit object in a chart.
 */
typedef NoteData =
{
	/**
	 * The timestamp of the note in milliseconds.
	 */
	var time:Float;

	/**
	 * The lane index (column) this note belongs to.
	 * e.g., 0=Left, 1=Down, 2=Up, 3=Right.
	 */
	var lane:Int;

	/**
	 * The duration of the note in milliseconds.
	 * 0 for a standard "tap" note.
	 */
	var ?length:Float;

	/**
	 * The type of note.
	 * null/empty = default.
	 * e.g., "mine", "alt_anim", "hey".
	 */
	var ?type:String;

	/**
	 * Optional parameters specific to the note type.
	 */
	var ?params:Array<Dynamic>;
};