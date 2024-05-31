package utilities;

class ValidateUtils
{
	public static final DEFAULT_CHAR_NAME:String = "bf";
	public static final DEFAULT_CHAR_HEALTH_COLOR:FlxColor = 0xFFFFFFFF;

	public static final DEFAULT_CHAR_IDLELIST:Array<String> = ["idle"];
	public static final DEFAULT_CHAR_SINGLIST:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];
	public static final DEFAULT_CHAR_MISSLIST:Array<String> = ["missLEFT", "missDOWN", "missUP", "missRIGHT"];

	public static final DEFAULT_CHAR_FLIP:AxePointData = {x: false, y: false};
	public static final DEFAULT_CHAR_SCALE:FloatPointData = {x: 1.0, y: 1.0};

	public static function validateCharData(data:CharacterData):CharacterData
	{
		if (data != null)
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

			data.idleList ??= DEFAULT_CHAR_IDLELIST;
			data.missList ??= DEFAULT_CHAR_SINGLIST;
			data.singList ??= DEFAULT_CHAR_MISSLIST;

			data.flip ??= DEFAULT_CHAR_FLIP;
			data.scale ??= DEFAULT_CHAR_SCALE;
		}

		return data;
	}

	public static final DEFAULT_FPS:Float = 24.0;

	public static function validateAnimData(data:AnimationData):AnimationData
	{
		if (data != null)
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

	public static function validateBoxStyle(data:Style):Style
	{
		if (data == null)
			data = Box.defaultStyle;
		else
		{
			data.width ??= Box.defaultStyle.width;
			data.height ??= Box.defaultStyle.height;

			data.bgColor ??= Box.defaultStyle.bgColor;

			data.topLeftSize ??= Box.defaultStyle.topLeftSize;
			data.topRightSize ??= Box.defaultStyle.topRightSize;
			data.botLeftSize ??= Box.defaultStyle.botLeftSize;
			data.botRightSize ??= Box.defaultStyle.botRightSize;

			data.cornerSize ??= Box.defaultStyle.cornerSize;
		}

		return data;
	}

	public static function validateButtonStyle(data:ButtonStyle):ButtonStyle
	{
		if (data == null)
		{
			data = Button.defaultButtonStyle;
		}
		else
		{
			data.hoverColor ??= Button.defaultButtonStyle.hoverColor;
			data.clickColor ??= Button.defaultButtonStyle.clickColor;
			data.textColor ??= Button.defaultButtonStyle.textColor;
			data.fontSize ??= Button.defaultButtonStyle.fontSize;
			data.font ??= Button.defaultButtonStyle.font;
		}

		return data;
	}

	public static function validateStepperStyle(data:StepperStyle):StepperStyle
	{
		if (data == null)
		{
			data = Stepper.defaultStepperStyle;
		}
		else
		{
			data.direction ??= Stepper.defaultStepperStyle.direction;
			data.gap ??= Stepper.defaultStepperStyle.gap;
			data.leftButtonStyle = ValidateUtils.validateButtonStyle(data.leftButtonStyle);
			data.rightButtonStyle = ValidateUtils.validateButtonStyle(data.rightButtonStyle);
			data.textColor ??= Stepper.defaultStepperStyle.textColor;
			data.font ??= Stepper.defaultStepperStyle.font;
			data.fontSize ??= Stepper.defaultStepperStyle.fontSize;
		}

		return data;
	}
}
