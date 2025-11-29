package crow.logics.tools;

import crow.logics.dependencies.LogicState;

class StringInterpolator
{
	private static final INTERPOLATION_REGEX = ~/(\${[a-zA-Z0-9_]+(?:\[[0-9]+\])?})/g;

	public static function interpolate(text:String, globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):String
	{
		return INTERPOLATION_REGEX.map(text, (regex) ->
		{
			final fullMatch = regex.matched(1);
			final expression = fullMatch.substring(2, fullMatch.length - 1);
			final parts = expression.split("[");
			final varName = parts[0];

			var value:Dynamic = null;

			// Priority: Local (Event) -> Entity (Object) -> Global (Menu)
			if (localState != null && localState.exists(varName))
				value = localState.get(varName);
			else if (entityState != null && entityState.exists(varName))
				value = entityState.get(varName);
			else if (globalState.exists(varName))
				value = globalState.get(varName);
			else
				return fullMatch;

			if (parts.length > 1)
			{
				final indexString = parts[1].substring(0, parts[1].length - 1);
				final index = Std.parseInt(indexString);
				if (index != null && Std.isOfType(value, Array) && index >= 0 && index < value.length)
					value = value[index];
				else
					return fullMatch;
			}

			return Std.string(value);
		});
	}
}
