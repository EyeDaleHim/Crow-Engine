package;

class Utilities
{
	public static function calcRelativeRect(spr:FlxSprite, rect:FlxRect):FlxRect
		return FlxRect.get(rect.x - spr.x, rect.y - spr.y, rect.width, rect.height);

	public inline static function indexOfCustom<T>(arr:Array<T>, x:T, ?fromIndex:Int = 0, ?toIndex:Int = null):Int
	{
		if (fromIndex < 0)
			fromIndex = 0;
		if (toIndex == null || toIndex > arr.length)
			toIndex = arr.length;

		for (i in fromIndex...toIndex)
		{
			if (arr[i] == x)
				return i;
		}

		return -1; // If not found
	}

	public inline static function pureFilename(fullPath:String)
		return Path.withoutDirectory(Path.withoutExtension(fullPath));
}
