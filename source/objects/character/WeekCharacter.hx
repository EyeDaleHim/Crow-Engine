package objects.character;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

@:allow(states.menus.StoryMenuState)
class WeekCharacter extends FlxSprite
{
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = [];
	public var confirmPose:String = ''; // leave blank to indicate no confirm pose

	private var _posing:Bool = true;

	override function new(x:Float, y:Float, char:String = "bf")
	{
		super(x, y);
	}
}
