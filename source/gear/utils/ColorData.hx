package gear.utils;

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
		else if (Reflect.isObject(value) && (Reflect.hasField(value, "r") || Reflect.hasField(value, "g") || Reflect.hasField(value, "b") || Reflect.hasField(value, "a")))
		{
			final r:Null<Int> = Reflect.getProperty(value, "r");
			final g:Null<Int> = Reflect.getProperty(value, "g");
			final b:Null<Int> = Reflect.getProperty(value, "b");
			final a:Null<Int> = Reflect.getProperty(value, "a");
			return FlxColor.fromRGB(r ?? 0, g ?? 0, b ?? 0, a ?? 255);
		}

		return null;
	}
}