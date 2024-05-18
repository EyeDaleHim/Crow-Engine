package backend.ui;

class Box extends FlxSprite
{
	static final defaultStyle:Style = {
		width: 128,
		height: 128,
		bgColor: 0xFF212328,
		topLeftSize: 0.0,
		topRightSize: 0.0,
		botLeftSize: 0.0,
		botRightSize: 0.0,
		cornerSize: 0.0
	};

    public var style:Style;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style)
	{
		super(x, y);

		if (style == null)
			style = defaultStyle;
		else
		{
			style.width ??= defaultStyle.width;
			style.height ??= defaultStyle.height;

			style.bgColor ??= defaultStyle.bgColor;

			style.topLeftSize ??= defaultStyle.topLeftSize;
			style.topRightSize ??= defaultStyle.topRightSize;
			style.botLeftSize ??= defaultStyle.botLeftSize;
			style.botRightSize ??= defaultStyle.botRightSize;

			style.cornerSize ??= defaultStyle.cornerSize;
		}

        this.style = style;

		if (style.topLeftSize > 0.0 || style.topRightSize > 0.0 || style.botLeftSize > 0.0 || style.botRightSize > 0.0)
		{
			makeGraphic(style.width, style.height, FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawRoundRectComplex(this, 0, 0, style.width, style.height, style.topLeftSize, style.topRightSize, style.botLeftSize,
				style.botRightSize);
		}
		else if (style.cornerSize > 0.0)
		{
			makeGraphic(style.width, style.height, FlxColor.TRANSPARENT, true);
			FlxSpriteUtil.drawRoundRect(this, 0, 0, style.width, style.height, style.cornerSize, style.cornerSize, style.bgColor);
		}
		else
			makeGraphic(style.width, style.height, style.bgColor);
	}
}
