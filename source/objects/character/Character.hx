package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;
import sys.FileSystem;

using StringTools;

class Character extends FlxSprite
{
	// basic info
	public var name:String = 'bf';
	public var isPlayer:Bool;

	// simple controls for your character
	public var controlIdle:Bool = true; // Whether or not your character should keep playing the idle when it finishes an animation.

	// animation stuff
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = []; // automatically defaults to the character data idle list

	// handled by this class
	private var _idleIndex:Int = 0;
	private var _animationTimer:Float = 0.0;

	public function new(x:Float, y:Float, name:String, isPlayer:Bool)
	{
		super(x, y);

		this.name = name;
		this.isPlayer = isPlayer;

		var imageExists:Bool = FileSystem.exists(Paths.image('characters/$name'));
		var xmlExists:Bool = FileSystem.exists(Paths.image('characters/$name').replace('png', 'xml'));
		var jsonExists:Bool = FileSystem.exists(Paths.image('characters/$name').replace('png', 'json'));

		if (!imageExists || !xmlExists || !jsonExists)
		{
			FlxG.log.error('Character $name doesn\'t exist! Please check your files!');
			this.name = 'bf';
		}
	}

	override function destroy()
	{
		super.destroy();

		animOffsets = null;
		idleList = null;
	}
}
