package utils;

class StringUtils
{
	public static function toTitleCase(value:String):String
	{
		var words:Array<String> = value.split(' ');
		var result:String = '';
		for (i in 0...words.length)
		{
			var word:String = words[i];
			result += word.charAt(0).toUpperCase() + word.substr(1).toLowerCase();
			if (i < words.length - 1)
			{
				result += ' ';
			}
		}
		return result;
	}

	public static function stripPrefix(value:String, prefix:String):String
	{
		if (value.startsWith(prefix))
		{
			return value.substr(prefix.length);
		}
		return value;
	}

	public static function stripSuffix(value:String, suffix:String):String
	{
		if (value.endsWith(suffix))
		{
			return value.substr(0, value.length - suffix.length);
		}
		return value;
	}

    public static function toKebabCase(value:String):String
    {
        return value.replace(' ', '-');
    }

	public static function toLowerKebabCase(value:String):String
	{
		return value.toLowerCase().replace(' ', '-');
	}

	public static function toUpperKebabCase(value:String):String
	{
		return value.toUpperCase().replace(' ', '-');
	}

	static final SANTIZE_REGEX:EReg = ~/[^-a-zA-Z0-9]/g;

	public static function sanitize(value:String):String
	{
		return SANTIZE_REGEX.replace(value, '');
	}

	public static function intToString(value:Int):String
	{
		return '$value';
	}

	public static function floatToString(value:Float):String
	{
		return '$value';
	}
}
