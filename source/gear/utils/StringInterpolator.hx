package gear.utils;

import haxe.ds.StringMap;
import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * A utility class for interpolating strings with values from a `logicState` map.
 * It supports simple variable replacement (e.g., `${variable}`) and array access (e.g., `${array[0]}`).
 */
class StringInterpolator
{
	private static final INTERPOLATION_REGEX = ~/(\${[a-zA-Z0-9_]+(?:\[[0-9]+\])?})/g;

	/**
	 * Interpolates a string with values from the provided `logicState`.
	 * @param text The string to interpolate, containing placeholders like `${variable}` or `${array[0]}`.
	 * @param logicState The map containing the data to use for interpolation.
	 * @return The interpolated string.
	 */
	public static function interpolate(text:String, logicState:Map<String, Dynamic>):String
	{
		return INTERPOLATION_REGEX.map(text, (regex) ->
		{
			final fullMatch = regex.matched(1);
			// Extract content between ${ and }
			final expression = fullMatch.substring(2, fullMatch.length - 1);

			// Check for array access, e.g., "myArray[0]"
			final parts = expression.split("[");
			final varName = parts[0];

			if (!logicState.exists(varName))
				return fullMatch; // Variable not found, return original placeholder

			var value = logicState.get(varName);

			if (parts.length > 1)
			{
				// Array access
				final indexString = parts[1].substring(0, parts[1].length - 1);
				final index = Std.parseInt(indexString);

				if (index != null && Std.isOfType(value, Array) && index >= 0 && index < value.length)
				{
					value = value[index];
				}
				else
					return fullMatch; // Invalid index or not an array
			}

			return Std.string(value);
		});
	}
}