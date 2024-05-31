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
				topRightSize: 4.0,
				botRightSize: 4.0
			}
		}
	};

	public var displayBox:Box;

	public var valueText:FlxText;

	public var leftButton:Button;
	public var rightButton:Button;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?stepperStyle:StepperStyle)
	{
		super(x, y);

		stepperStyle = ValidateUtils.validateStepperStyle(stepperStyle);

		displayBox = new Box(x, y, style);

		if (stepperStyle.direction == UP || stepperStyle.direction == DOWN)
			stepperStyle.direction = RIGHT;

		leftButton = new Button(stepperStyle.leftButtonStyle.overrideStyle ?? style, stepperStyle.leftButtonStyle, "-");
		rightButton = new Button(stepperStyle.rightButtonStyle.overrideStyle ?? style, stepperStyle.rightButtonStyle, "+");

		var buttonRect:FlxRect = FlxRect.get();
		buttonRect.setSize(leftButton.width + 1, leftButton.height);
		buttonRect.width += rightButton.width;

		if (stepperStyle.direction == LEFT)
			buttonRect.right = x - stepperStyle.gap;
		else if (stepperStyle.direction == RIGHT)
			buttonRect.x = x + stepperStyle.gap;
	}

	override public function draw()
	{
		super.draw();

		leftButton.draw();
		rightButton.draw();
	}
}

typedef StepperStyle =
{
	@:optional var direction:FlxDirection;

	@:optional var gap:Float;

	@:optional var leftButtonStyle:ButtonStyle;
	@:optional var rightButtonStyle:ButtonStyle;

	@:optional var textColor:FlxColor;
	@:optional var fontSize:Int;
	@:optional var font:String;
}
