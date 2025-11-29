package crow.assets.metadata.helpers;

import flixel.tweens.FlxEase;

/**
 * A helper abstract for handling easing functions from strings.
 * Used primarily in metadata parsing.
 */
abstract EaseData(String) from String to String
{
	/*
	 *	Resolves the string to a FlxEase function.
	 *	If the string does not correspond to a valid easing function,
	 *	FlxEase.linear is returned.
	 *	@return The corresponding EaseFunction.
	 */
	public function getEase():EaseFunction
	{
		if (this == null || this.length == 0)
			return FlxEase.linear;
		// Direct reflection check (Case-sensitive: "quadOut", "linear", etc.)
		var func = Reflect.field(FlxEase, this);
		if (Reflect.isFunction(func))
			return func;
		// Fallback: If not found, try to match case-insensitive for common errors
		final lowerName = this.toLowerCase();
		for (field in Type.getClassFields(FlxEase))
		{
			if (field.toLowerCase() == lowerName)
			{
				func = Reflect.field(FlxEase, field);
				if (Reflect.isFunction(func))
					return func;
			}
		}

		return FlxEase.linear;
	}
}
