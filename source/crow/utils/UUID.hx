package crow.utils;

class UUID
{
	public static function generateV4():String
	{
		var chars = "0123456789abcdef".split("");
		var uuid:Array<String> = [];
		var rnd:Float = 0;
		var r:Int;

		for (i in 0...36)
		{
			if (i == 8 || i == 13 || i == 18 || i == 23)
			{
				uuid[i] = "-";
			}
			else if (i == 14)
			{
				uuid[i] = "4"; // Version 4
			}
			else
			{
				if (rnd <= 0x02)
					rnd = Std.int(0x2000000 + (Math.random() * 0x1000000)) | 0;
				r = Std.int(rnd) & 0xf;
				rnd = Std.int(rnd) >> 4;
				uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r]; // Variant (8, 9, a, or b)
			}
		}
		return uuid.join("");
	}
}
