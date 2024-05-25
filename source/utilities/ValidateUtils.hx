package utilities;

class ValidateUtils
{
	public static final DEFAULT_CHAR_NAME:String = "bf";
	public static final DEFAULT_CHAR_HEALTH_COLOR:FlxColor = 0xFFFFFFFF;
	
	public static function validateCharData(data:CharacterData):CharacterData
	{
		if (data == null)
			return null;
		else
		{
			data.name ??= "bf";

			if (data.animations?.length > 0)
			{
				for (anim in data.animations)
				{
					anim = validateAnimData(anim);
				}
			}

			data.healthColor ??= DEFAULT_CHAR_HEALTH_COLOR;

			data.idleList;
			data.missList;
			data.singList;

			data.flip;
			data.scale;
		}
	}

	public static final DEFAULT_FPS:Float = 24.0;

	public static function validateAnimData(data:AnimationData):AnimationData
	{
		if (data == null)
			return null;
		else
		{
			data.name ??= "";
			data.prefix ??= "";
			data.indices ??= [];
			data.fps ??= DEFAULT_FPS;
			data.looped ??= false;
			data.offset ??= {x: 0, y: 0};
		}

		return data;
	}
}
