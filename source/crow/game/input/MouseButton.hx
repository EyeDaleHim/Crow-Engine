package crow.game.input;

enum abstract MouseButton(String) from String to String
{
	var Left = "LMB";
	var Middle = "MMB";
	var Right = "RMB";

	public static final ID_LEFT = 0;
	public static final ID_MIDDLE = 1;
	public static final ID_RIGHT = 2;

	/**
	 * Converts a MouseButton instance to its unique integer ID.
	 * @param button The MouseButton to convert.
	 * @return The integer ID, or -1 if not found.
	 */
	public static function toId(button:MouseButton):Int
	{
		return switch (button)
		{
			case Left: ID_LEFT;
			case Middle: ID_MIDDLE;
			case Right: ID_RIGHT;
			default: -1;
		}
	}

	/**
	 * Converts a string representation (e.g., "LMB") to its unique integer ID.
	 * This is useful for parsing from configuration files.
	 * @param s The string to convert.
	 * @return The integer ID, or -1 if not found.
	 */
	public static function stringToId(s:String):Int
	{
		return switch (s.toUpperCase())
		{
			case "LMB": ID_LEFT;
			case "MMB": ID_MIDDLE;
			case "RMB": ID_RIGHT;
			default: -1;
		}
	}

	/**
	 * Converts a unique integer ID to its string representation (e.g., 0 -> "LMB").
	 * @param id The integer ID to convert.
	 * @return The string representation, or null if not found.
	 */
	public static function idToString(id:Int):String
	{
		return switch (id)
		{
			case ID_LEFT: Left;
			case ID_MIDDLE: Middle;
			case ID_RIGHT: Right;
			default: null;
		}
	}
}