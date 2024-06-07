package utils;

class ObjectUtils
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
}
