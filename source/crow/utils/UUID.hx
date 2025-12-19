package crow.utils;

class UUID
{
	// Standard Regex for validation
	public static final VALIDATOR = ~/[0-9a-f]{8}-[0-9a-f]{4}-[1-7][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}/i;

	/**
	 * Generates a UUID v4 (random).
	 * @return A new UUID v4 string.
	 */
	public static function generateV4():String
	{
		var buf = new StringBuf();
		var chars = "0123456789abcdef";

		for (i in 0...36)
		{
			if (i == 8 || i == 13 || i == 18 || i == 23)
			{
				buf.add("-");
			}
			else if (i == 14)
			{
				buf.add("4");
			}
			else
			{
				var r = Std.int(Math.random() * 16);
				if (i == 19)
					r = (r & 0x3) | 0x8;
				buf.add(chars.charAt(r));
			}
		}
		return buf.toString();
	}

	public static function isValid(uuid:String):Bool
	{
		return VALIDATOR.match(uuid);
	}
}
