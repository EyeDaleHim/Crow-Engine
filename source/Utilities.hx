package;

class Utilities
{
	inline public static function objRight(obj:FlxObject):Float
	{
		if (obj == null)
			return 0.0;
		return obj.x + obj.width;
	}

	inline public static function objBottom(obj:FlxObject):Float
	{
		if (obj == null)
			return 0.0;
		return obj.y + obj.height;
	}

	public static function centerOverlay(object:FlxObject, base:FlxObject, axes:FlxAxes = XY):FlxObject
	{
		if (object == null || base == null)
			return object;

		if (axes.x)
			object.x = base.x + (base.width / 2) - (object.width / 2);

		if (axes.y)
			object.y = base.y + (base.height / 2) - (object.height / 2);

		return object;
	}

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
