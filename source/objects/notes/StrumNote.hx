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

		animation.addByPrefix(staticAnim, if (direction == 0) "arrowL" else if (direction == 1) "arrowD" else if (direction == 2) "arrowU" else "arrowR");
		animation.addByPrefix(pressAnim, if (direction == 0) "left p" else if (direction == 1) "down p" else if (direction == 2) "up p" else "right p");
		animation.addByPrefix(confirmAnim, if (direction == 0) "left c" else if (direction == 1) "down c" else if (direction == 2) "up c" else "right c");

        animation.play(staticAnim);

        scale.set(0.7, 0.7);
		updateHitbox();

        antialiasing = true;
	}
}
