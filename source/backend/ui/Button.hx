package backend.ui;

class Button extends Box
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

	static final defaultButtonStyle:ButtonStyle = {
		hoverColor: 0xFF6B6B6B,
		clickColor: 0xFF585858,
		textColor: FlxColor.WHITE,
		fontSize: 16,
		font: "",
		autoSize: false
	};

	public var buttonStyle:ButtonStyle;
    public var textObject:FlxText;

    public var checkOverlap:Void->FlxPoint; // useful if you have your custom mouse or whatever, if null, button uses FlxG.mouse by default
    
    public var onHover:Void->Void;
    public var onClick:Void->Void;

    private var _overlapping:Bool = false;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?buttonStyle:ButtonStyle, ?text:String = "")
	{
		if (buttonStyle == null)
		{
			buttonStyle = defaultButtonStyle;
		}
		else
		{
			buttonStyle.hoverColor ??= defaultButtonStyle.hoverColor;
			buttonStyle.clickColor ??= defaultButtonStyle.clickColor;
			buttonStyle.textColor ??= defaultButtonStyle.textColor;
			buttonStyle.fontSize ??= defaultButtonStyle.fontSize;
			buttonStyle.font ??= defaultButtonStyle.font;
			buttonStyle.autoSize ??= defaultButtonStyle.autoSize;
		}

		this.buttonStyle = buttonStyle;

		textObject = new FlxText(text, buttonStyle.fontSize);
		textObject.setFormat(Assets.font(buttonStyle.font).fontName, buttonStyle.fontSize, buttonStyle.textColor);

		var actualColor:FlxColor;

		if (style == null)
		{
			style = defaultStyle;
			actualColor = style.bgColor;
		}
		else
		{
			actualColor = style.bgColor;
		}

		style.bgColor = FlxColor.WHITE;

		if (buttonStyle.autoSize)
		{
			style.width = Math.floor(textObject.width + 16);
			style.height = Math.floor(textObject.height + 8);
		}

		super(x, y, style);

        style.bgColor = actualColor;

		textObject.centerOverlay(this, XY);

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

	override public function draw()
	{
		super.draw();
		textObject.draw();
	}
}

typedef ButtonStyle =
{
	@:optional var hoverColor:FlxColor;
	@:optional var clickColor:FlxColor;

	@:optional var textColor:FlxColor;

	@:optional var font:String;
	@:optional var fontSize:Int;

	@:optional var autoSize:Bool;
};
