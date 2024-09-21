package backend.ui;

import flixel.util.FlxDirection;

class Stepper extends FlxObject
{
	public static final defaultStepperStyle:StepperStyle = {
		direction: RIGHT,
		gap: 8.0,
		leftButtonStyle: {
			hoverColor: 0xFF6B6B6B,
			clickColor: 0xFF585858,
			textColor: FlxColor.WHITE,
			fontSize: 16,
			font: "vcr",
			autoSize: XY,
			overrideStyle: {
				bgColor: 0xFF212328,
				topLeftSize: 4.0,
				botLeftSize: 4.0
			}
		},
		rightButtonStyle: {
			hoverColor: 0xFF6B6B6B,
			clickColor: 0xFF585858,
			textColor: FlxColor.WHITE,
			fontSize: 16,
			font: "vcr",
			autoSize: XY,
			overrideStyle: {
				bgColor: 0xFF212328,
				topRightSize: 4.0,
				botRightSize: 4.0
			}
		},
		fontSize: 16,
		font: "vcr",
		textColor: FlxColor.WHITE
	};

	public var displayBox:Box;

	public var valueText:FlxText;

	public var leftButton:Button;
	public var rightButton:Button;

	@:isVar public var value(get, set):Float;

	public var stepValue:Float = 1.0;

	public var getValue:Void->Float;
	public var setValue:Float->Void;

	public var minValue:Null<Float> = null;
	public var maxValue:Null<Float> = null;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?stepperStyle:StepperStyle, ?getValue:Void->Float, ?setValue:Float->Void)
	{
		super(x, y);

		this.getValue = getValue;
		this.setValue = setValue;

		stepperStyle = ValidateUtils.validateStepperStyle(stepperStyle);

		valueText = new FlxText("0", stepperStyle.fontSize);
		valueText.setFormat(Assets.font(stepperStyle.font).fontName, stepperStyle.fontSize, stepperStyle.textColor);

		if (style == null)
			style = {bgColor: 0xFF212328, width: Math.floor(valueText.width + 48), height: Math.floor(valueText.height + 8)};
		else
		{
			style.width = Math.floor(valueText.width + 48);
			style.height = Math.floor(valueText.height + 8);
		}

		displayBox = new Box(x, y, style);
		
		if (stepperStyle.direction == UP || stepperStyle.direction == DOWN)
			stepperStyle.direction = RIGHT;

		leftButton = new Button(stepperStyle.leftButtonStyle.overrideStyle ?? style, stepperStyle.leftButtonStyle, "-");
		rightButton = new Button(stepperStyle.rightButtonStyle.overrideStyle ?? style, stepperStyle.rightButtonStyle, "+");

		leftButton.onClick = function()
		{
			if (minValue != null && minValue - stepValue < minValue)
				return;

			value -= stepValue;

			valueText.text = '$value';
			valueText.centerOverlay(displayBox, XY);
		};

		rightButton.onClick = function()
		{
			if (maxValue != null && maxValue + stepValue > maxValue)
				return;

			value += stepValue;

			valueText.text = '$value';
			valueText.centerOverlay(displayBox, XY);
		};

		var buttonRect:FlxRect = FlxRect.get();
		buttonRect.setSize(leftButton.width + 1, leftButton.height);
		buttonRect.width += rightButton.width;

		if (stepperStyle.direction == LEFT)
			buttonRect.right = displayBox.x - stepperStyle.gap;
		else if (stepperStyle.direction == RIGHT)
			buttonRect.x = (displayBox.x + displayBox.width) + stepperStyle.gap;
		buttonRect.y = displayBox.y;

		leftButton.setPosition(buttonRect.x, buttonRect.y);
		rightButton.setPosition(buttonRect.right - rightButton.width, buttonRect.y);

		width = stepperStyle.gap + displayBox.width + buttonRect.width;
		height = stepperStyle.gap + displayBox.width + buttonRect.height;

		valueText.centerOverlay(displayBox, XY);
	}

	override public function update(elapsed:Float)
	{
		displayBox.update(elapsed);
		valueText.update(elapsed);
		leftButton.update(elapsed);
		rightButton.update(elapsed);

		super.update(elapsed);
	}

	override public function draw()
	{
		super.draw();

		displayBox.draw();
		valueText.draw();
		leftButton.draw();
		rightButton.draw();
	}

	function get_value():Float
	{
		if (getValue == null)
			return value;

		return getValue();
	}

	function set_value(NewValue:Float):Float
	{
		if (setValue != null)
		{
			setValue(NewValue);
			return NewValue;
		}

		return (value = NewValue);
	}
}

typedef StepperStyle =
{
	var ?direction:FlxDirection;

	var ?gap:Float;

	var ?leftButtonStyle:ButtonStyle;
	var ?rightButtonStyle:ButtonStyle;

	var ?textColor:FlxColor;
	var ?fontSize:Int;
	var ?font:String;
}
