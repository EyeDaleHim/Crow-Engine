package system;

class Assets
{
	public static final graphicCache:Map<String, FlxGraphic> = [];
	public static final soundCache:Map<String, Sound> = [];

    inline public static function assetPath(path:String):String
    {
    }

	inline public static function imagePath(path:String):String
	{
	}

	inline public static function soundPath(path:String, type:SoundType):String
	{
	}

	inline public static function musicPath(path:String):String
	{
	}

	inline public static function sfxPath(path:String):String
	{
	}

    public static function readBytes(path:String):Bytes
    {
    }

    public static function readText(path:String):String
    {
    }

    public static function image(path:String, hardware:Bool = true):FlxGraphic
    {}

    public static function music(path:String):Sound
    {}

    public static function sfx(path:String):Sound
    {}

    public static function sound(path:String):Sound
    {}
}

enum abstract SoundType(String)
{
	var music:SoundType = "music";
	var sfx:SoundType = "sfx";
}
