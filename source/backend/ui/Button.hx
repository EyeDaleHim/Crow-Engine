package backend.ui;

class Button extends Box
{
	public static final defaultStyle:Style = {
		width: 128,
		height: 128,
		bgColor: 0xFF212328,
		topLeftSize: 0.0,
		topRightSize: 0.0,
		botLeftSize: 0.0,
		botRightSize: 0.0,
		cornerSize: 0.0
	};

	public static final defaultButtonStyle:ButtonStyle = {
		hoverColor: 0xFF6B6B6B,
		clickColor: 0xFF585858,
		textColor: FlxColor.WHITE,
		fontSize: 16,
		font: "vcr",
		alignment: CENTER,
		alignGap: 4.0,
		autoSize: XY
	};

	public var buttonStyle:ButtonStyle;
	public var textDisplay:FlxText;

	public var checkOverlap:Void->FlxPoint; // useful if you have your custom mouse or whatever, if null, button uses FlxG.mouse by default

	public var onHover:Void->Void;
	public var onClick:Void->Void;

	private var _overlapping:Bool = false;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?buttonStyle:ButtonStyle, ?text:String = "")
	{
		buttonStyle = ValidateUtils.validateButtonStyle(buttonStyle);
		this.buttonStyle = buttonStyle;

		textDisplay = new FlxText(text, buttonStyle.fontSize);
		textDisplay.setFormat(Assets.font(buttonStyle.font).fontName, buttonStyle.fontSize, buttonStyle.textColor);

		if (style == null)
			style = defaultStyle;

		if (buttonStyle.autoSize?.x)
			style.width = Math.floor(textDisplay.width + 16);
		if (buttonStyle.autoSize?.y)
			style.height = Math.floor(textDisplay.height + 8);

		var actualColor:FlxColor = (buttonStyle.overrideStyle ?? style).bgColor;
		(buttonStyle.overrideStyle ?? style).bgColor = FlxColor.WHITE;
		super(x, y, buttonStyle.overrideStyle ?? style);
		style.bgColor = actualColor;

		alignDisplay();

		color = style.bgColor;
	}

	override public function update(elapsed:Float)
	{
		if (checkOverlap != null)
		{
			_overlapping = overlapsPoint(checkOverlap());
		}
		else
		{
			_overlapping = FlxG.mouse.overlaps(this);
		}

		if (_overlapping)
		{
			if (FlxG.mouse.pressed)
			{
				color = buttonStyle.clickColor;
				alpha = buttonStyle.clickColor.alphaFloat;
			}
			else
			{
				color = buttonStyle.hoverColor;
				alpha = buttonStyle.hoverColor.alphaFloat;
			}

			if (FlxG.mouse.justReleased && onClick != null)
			{
				onClick();
			}
		}
		else
		{
			color = style.bgColor;
			alpha = style.bgColor.alphaFloat;
		}

		super.update(elapsed);
	}

	public function alignDisplay()
	{
		switch (buttonStyle.alignment)
		{
			case CENTER:
				textDisplay.centerOverlay(this, XY);
			case LEFT:
				textDisplay.centerOverlay(this, Y);
				textDisplay.x = x + buttonStyle.alignGap;
			case RIGHT:
				textDisplay.centerOverlay(this, Y);
				textDisplay.x = this.objRight() - textDisplay.width - buttonStyle.alignGap;
			case TOP:
				textDisplay.centerOverlay(this, X);
				textDisplay.y = y + buttonStyle.alignGap;
			case BOTTOM:
				textDisplay.centerOverlay(this, X);
				textDisplay.y = this.objBottom() - textDisplay.height - buttonStyle.alignGap;
		}
	}

	override public function draw()
	{
		super.draw();
		textDisplay.draw();
	}

	override function set_x(Value:Float):Float
	{
		x = Value;

		alignDisplay();

		return Value;
	}

	override function set_y(Value:Float):Float
	{
		y = Value;

		alignDisplay();

		return Value;
	}
}

typedef ButtonStyle =
{
	var ?hoverColor:FlxColor;
	var ?clickColor:FlxColor;

	var ?textColor:FlxColor;

	var ?font:String;
	var ?fontSize:Int;

	var ?alignment:TextAlignment;
	var ?alignGap:Float;

	var ?autoSize:FlxAxes;

	var ?overrideStyle:Style;
};

enum TextAlignment
{
	LEFT;
	RIGHT;
	BOTTOM;
	TOP;
	CENTER;
}
