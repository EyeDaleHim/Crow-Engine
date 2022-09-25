package utils;

import flixel.math.FlxMath;

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
}
