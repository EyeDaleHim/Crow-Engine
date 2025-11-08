package crow.logics.tools;

import crow.logics.dependencies.LogicState;
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
	 * @param globalState The primary map containing data for interpolation.
	 * @param localState An optional secondary map to check for data first.
	 * @return The interpolated string.
	 */
	public static function interpolate(text:String, globalState:LogicState, ?localState:LogicState):String
	{
		return INTERPOLATION_REGEX.map(text, (regex) ->
		{
			final fullMatch = regex.matched(1);
			// Extract content between ${ and }
			final expression = fullMatch.substring(2, fullMatch.length - 1);

			// Check for array access, e.g., "myArray[0]"
			final parts = expression.split("[");
			final varName = parts[0];

			var value:Dynamic = null;
			var stateUsed:LogicState = null;

			if (localState != null && localState.exists(varName))
			{
				value = localState.get(varName);
			}
			else if (globalState.exists(varName))
			{
				value = globalState.get(varName);
			}
			else
				return fullMatch; // Variable not found in any scope

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