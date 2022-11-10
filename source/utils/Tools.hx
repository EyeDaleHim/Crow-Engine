package utils;

import objects.Stage.SimplePoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxAxes;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import sys.FileSystem;

using StringTools;

class Tools
{
	public static function lerpBound(a:Float, b:Float, ratio:Float):Float
	{
		return a + FlxMath.bound(ratio, 0, 1) * (b - a);
	}

	public static function formatMemory(num:UInt):String
	{
		var size:Float = num;
		var data = 0;
		var dataTexts = ["B", "KB", "MB", "GB", "TB", "PB"];
		while (size > 1024 && data < dataTexts.length - 1)
		{
			data++;
			size = size / 1024;
		}

		size = Math.round(size * 100) / 100;
		var formatSize:String = formatAccuracy(size);
		return formatSize + " " + dataTexts[data];
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
		var conversion:Map<String, String> = [
			'0' => '0.00',
			'0.0' => '0.00',
			'0.00' => '0.00',
			'00' => '00.00',
			'00.0' => '00.00',
			'00.00' => '00.00',
			'000' => '000.00'
		];

		var stringVal:String = Std.string(value);
		var converVal:String = '';
		for (i in 0...stringVal.length)
		{
			if (stringVal.charAt(i) == '.')
				converVal += '.';
			else
				converVal += '0';
		}

		var wantedConversion:String = conversion.get(converVal);
		var convertedValue:String = '';

		for (i in 0...wantedConversion.length)
		{
			if (stringVal.charAt(i) == '')
				convertedValue += wantedConversion.charAt(i);
			else
				convertedValue += stringVal.charAt(i);
		}

		if (convertedValue.length == 0)
			return '$value';

		return convertedValue;
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
		if (axes.match(X | XY))
			object.x = FlxMath.remapToRange(object.x, 0, FlxG.width, margin.x, margin.width);
		if (axes.match(Y | XY))
			object.y = FlxMath.remapToRange(object.y, 0, FlxG.height, margin.y, margin.height);

		return object;
	}

	public static function centerOverlay(object:FlxObject, base:FlxObject, axes:FlxAxes = XY):FlxObject
	{
		if (axes.match(X | XY))
			object.x = base.x + (base.width / 2) - (object.width / 2);

		if (axes.match(Y | XY))
			object.y = base.y + (base.height / 2) - (object.height / 2);

		return object;
	}

	public static function formatToReadable(string:String):String
	{
		string.replace(' ', '-');
		string.toLowerCase();

		return string;
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
