package utils;

import objects.Stage.SimplePoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxAxes;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import sys.FileSystem;
import lime.utils.Assets;

using StringTools;

class Tools
{
	public static function lerpBound(a:Float, b:Float, ratio:Float):Float
	{
		return a + FlxMath.bound(ratio, 0, 1) * (b - a);
	}

	public static function abbreviateNumber(num:UInt, sizeDivision:Float = 1000, dataAbbreviation:Array<String>):String
	{
		if (dataAbbreviation.length == 0)
			return "" + num;

		var size:Float = num;
		var data = 0;

		while (size > sizeDivision && data < dataAbbreviation.length - 1)
		{
			data++;
			size = size / sizeDivision;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return formatSize + " " + dataAbbreviation[data];
	}

	public static function numberArray(min:Int, max:Int, ?exclude:Array<Int>):Array<Int>
	{
		var numArray:Array<Int> = [];

		if (exclude == null)
			exclude = [];

		for (i in min...max)
		{
			if (exclude.indexOf(i) == -1)
				numArray.push(i);
		}

		return numArray;
	}

	public static function formatAccuracy(value:Float)
	{
		var str = Std.string(value);
		if (str.indexOf(".") == -1)
			str += ".00";
		return str.split('.')[0] + '.' + str.split('.')[1].rpad("0", 2);
	}

	public static function utcToDate(time:Int, format:String):String
	{
		var date:Date = (time == 0 ? Date.now() : Date.fromTime(time));

		var dateMapping:Map<String, Int> = [
			'yyyy' => date.getFullYear(),
			'mm' => date.getMonth() + 1,
			'dd' => date.getDay() + 1
		];

		var returnedFormat:String = format;

		for (dateMap in dateMapping.keys())
		{
			returnedFormat = returnedFormat.replace(dateMap, Std.string(dateMapping[dateMap]));
		}

		return returnedFormat;
	}

	public static function translateToMargin(object:FlxObject, margin:ScreenMargin, axes:FlxAxes = XY):FlxObject
	{
		if (axes.x)
			object.x = FlxMath.remapToRange(object.x, 0, FlxG.width, margin.x, margin.width);
		if (axes.y)
			object.y = FlxMath.remapToRange(object.y, 0, FlxG.height, margin.y, margin.height);

		return object;
	}

	public static function centerOverlay(object:FlxObject, base:FlxObject, axes:FlxAxes = XY):FlxObject
	{
		if (axes.x)
			object.x = base.x + (base.width / 2) - (object.width / 2);

		if (axes.y)
			object.y = base.y + (base.height / 2) - (object.height / 2);

		return object;
	}

	public static function calcRectOnStatusPosition(sprite:FlxSprite, rectangle:FlxRect)
	{
		return new FlxRect(rectangle.x - sprite.x, rectangle.y - sprite.y, rectangle.width, rectangle.height);
	}

	// html5 support, will do this later
	public static function fileExists(file:String):Bool
	{
		#if sys
		return FileSystem.exists(file);
		#else
		return Assets.exists(file);
		#end

		return false;
	}

	public static function formatToReadable(string:String):String
	{
		return string.replace(' ', '-').toLowerCase();
	}

	public static function transformSimplePoint(fromPoint:FlxPoint, toPoint:SimplePoint):FlxPoint
	{
		return fromPoint.set(toPoint.x, toPoint.y);
	}
}

typedef ScreenMargin =
{
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
}
