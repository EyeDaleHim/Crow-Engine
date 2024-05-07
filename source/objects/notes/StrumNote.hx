package objects.notes;

class StrumNote extends FlxSprite
{
	public var direction:Int = 0;
	public var confirmAnim:String = 'confirm';
	public var pressAnim:String = 'press';
	public var staticAnim:String = 'static';

	public var downScroll:Bool = false;

	private var animOffsets:Map<String, FlxPoint> = [];

	public function new(direction:Int = 0)
	{
		super();

		this.direction = direction;

		frames = Assets.frames("game/ui/NOTE_assets");

		// temp stand-ins

		animation.addByPrefix(staticAnim,
			if (direction == 0) "arrowLEFT" else if (direction == 1) "arrowDOWN" else if (direction == 2) "arrowUP" else "arrowRIGHT");
		animation.addByPrefix(pressAnim,
			if (direction == 0) "left press" else if (direction == 1) "down press" else if (direction == 2) "up press" else "right press", 24, false);
		animation.addByPrefix(confirmAnim,
			if (direction == 0) "left confirm" else if (direction == 1) "down confirm" else if (direction == 2) "up confirm" else "right confirm", 24, false);

		animation.play(staticAnim);

		scale.set(0.7, 0.7);
		updateHitbox();

		antialiasing = true;
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(AnimName))
			offsetAnim.set(animOffsets[AnimName].x, animOffsets[AnimName].y);
		else
			centerOffsets();
		centerOrigin();
	}
}
