package crow.utils;

import flixel.util.FlxColor;

/**
 * A utility class that facilitates converting various color representations
 * (from JSON or other sources) into a `FlxColor`. This is often used
 * with `@:genericBuild` to provide automatic type coercion.
 *
 * It can handle:
 * - Integers (e.g., `0xFF0000`)
 * - Hexadecimal strings (e.g., `"0xFF0000"` or `"#FF0000"`)
 * - Objects with optional `r`, `g`, `b` properties (e.g., `{ "r": 255, "g": 0, "b": 0 }`). Missing fields default to 0.
 *   - An optional `a` property (0-255) can be included for alpha.
 */
@:final
class ColorData
{
	public static function fromDynamic(value:Dynamic):Null<FlxColor>
	{
		if (value == null)
			return null;

		if (Std.isOfType(value, Int))
		{
			return FlxColor.fromInt(value);
		}
		else if (Std.isOfType(value, String))
		{
			return FlxColor.fromString(value);
		}
		// Treat as a color object if it has at least one of the expected color properties.
		else if (value.r != null || value.g != null || value.b != null || value.a != null)
		{
			final r:Null<Int> = value.r ?? 0;
			final g:Null<Int> = value.g ?? 0;
			final b:Null<Int> = value.b ?? 0;
			final a:Null<Int> = value.a ?? 255;
			return FlxColor.fromRGB(r, g, b, a);
		}

		return null;
	}
}