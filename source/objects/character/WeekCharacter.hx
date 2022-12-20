package objects.character;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class WeekCharacter extends FlxSprite
{
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = [];

	override function new(x:Float, y:Float, char:String = "bf")
	{
		super(x, y);
	}
}
