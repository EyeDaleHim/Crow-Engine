package objects.ui;

import objects.handlers.IFunkinSprite;

class WeekSprite extends FlxSprite implements IFunkinSprite
{
	public var targetY:Float = 0;
	public var isFlashing:Bool = false;

	private var _flashElapsed:Float = 0.0;

	override public function new(x:Float = 0, y:Float = 0, week:String = 'tutorial')
	{
		super(x, y);

		loadGraphic(Paths.image('menus/storymenu/weeks/$week'));
	}

	override function update(elapsed:Float)
	{
		if (isFlashing)
		{
			if ((_flashElapsed += elapsed) >= 1 / 25)
			{
				_flashElapsed -= 1 / 25;

				color = (color == FlxColor.WHITE ? FlxColor.CYAN : FlxColor.WHITE);
			}
		}
		else
		{
			_flashElapsed = 0.0;
			color = FlxColor.WHITE;
		}

		super.update(elapsed);
	}
}
