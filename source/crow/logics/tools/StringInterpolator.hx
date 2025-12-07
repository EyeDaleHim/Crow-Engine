package crow.logics.tools;

import crow.logics.dependencies.LogicContext;
import crow.logics.dependencies.LogicState;
import crow.logics.tools.ActionScope;

class StringInterpolator
{
	private static final INTERPOLATION_REGEX = ~/(\${[a-zA-Z0-9_.]+(?:\[[0-9]+\])?})/g;

	public static function interpolate(text:String, context:ILogicContext):String
	{
		return INTERPOLATION_REGEX.map(text, (regex) ->
		{
			final fullMatch = regex.matched(1);
			final expression = fullMatch.substring(2, fullMatch.length - 1); // remove ${ and }
			final parts = expression.split("[");
			var varPath = parts[0];

			var value:Dynamic = null;

			// Check for explicit scoping (e.g. "settings.volume")
			if (varPath.indexOf(".") != -1)
			{
				final pathParts = varPath.split(".");
				final scope = pathParts[0];
				final key = pathParts[1];
				
				final state = context.getState(scope);
				if (state != null && state.exists(key))
				{
					value = state.get(key);
				}
			}
			else
			{
				// Legacy Priority: Local -> Entity -> Global
				var local = context.getState(ActionScope.LOCAL);
				var entity = context.getState(ActionScope.ENTITY);
				var global = context.getState(ActionScope.GLOBAL);

				if (local != null && local.exists(varPath))
					value = local.get(varPath);
				else if (entity != null && entity.exists(varPath))
					value = entity.get(varPath);
				else if (global != null && global.exists(varPath))
					value = global.get(varPath);
				else
					return fullMatch; // Variable not found
			}

			// Handle Array Indexing
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