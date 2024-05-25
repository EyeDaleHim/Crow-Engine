package objects.characters;

class Bopper extends Prop
{
	public var beatBop:Int = 1;

	public var bopList:Array<String> = [];

	public var animOffsets:Map<String, FlxPoint> = [];
	public var globalOffset:FlxPoint = FlxPoint.get();

	public var bopIndex:Int = 0;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, name:String = "")
	{
		super(x, y, name);
	}

	public function playAnimation(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0)
	{
        animation.play(name, force, reversed, frame);

        offset.copyFrom(globalOffset);

        if (animOffsets.exists(name))
            offset += animOffsets.get(name);
	}

	override public function beatHit()
	{
		// pre super.beatHit();

		if (beatBop > 0 && bopList.length > 0)
		{
			bopIndex++;
			bopIndex %= bopList.length;
		}

		super.beatHit();
	}
}
