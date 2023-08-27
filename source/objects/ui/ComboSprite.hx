package objects.ui;

class ComboSprite extends FlxSprite
{
	public var delay:Float = 0.0;

	override public function new(?X:Float = 0, ?Y:Float = 0)
	{
		super(X, Y);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (alpha <= 0.0)
			active = false;
		else if (delay >= 0.0)
			delay -= elapsed;
		else
			alpha -= (1.0 / 0.2) * elapsed;
	}

	public function cloneCombo():ComboSprite
	{
		return (new ComboSprite()).loadGraphicFromCombo(this);
	}

	public function loadGraphicFromCombo(Sprite:ComboSprite):ComboSprite
	{
		frames = Sprite.frames;
		bakedRotationAngle = Sprite.bakedRotationAngle;
		if (bakedRotationAngle > 0)
		{
			width = Sprite.width;
			height = Sprite.height;
			centerOffsets();
		}
		antialiasing = Sprite.antialiasing;
		animation.copyFrom(Sprite.animation);
		graphicLoaded();
		clipRect = Sprite.clipRect;
		return this;
	}
}
