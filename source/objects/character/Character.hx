package objects.character;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxStringUtil;
import haxe.Json;
import openfl.Assets;
import sys.FileSystem;
import objects.character.CharacterData;

using StringTools;

class Character extends FlxSprite
{
	// basic info
	public var name:String = 'bf';
	public var isPlayer:Bool = true;
	public var healthColor:Int = 0;

	// simple controls for your character
	public var controlIdle:Bool = true; // Whether or not your character should keep playing the idle when it finishes an animation.
	public var singAnimsUsesMulti:Bool = false; // If this is enabled, the sing animation will hold for (Conductor.crochet / 1000) * idleDuration, else, it'll just be idleDuration
	public var idleDuration:Float = 0.65; // The amount of seconds (or multiplication) on when the idle animation should be played after the sing animation
	public var overridePlayer:Bool = false; // If you set this to true, the enemy will be treated as a player

	// animation stuff
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = []; // automatically defaults to the character data idle list
	public var singList:Array<String> = [];

	// handled by this class
	private var _idleIndex:Int = 0;
	private var _animationTimer:Float = 0.0;
	private var _characterData:CharacterData;

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

		frames = Paths.getSparrowAtlas('characters/$name');

		_characterData = Json.parse(Assets.getText(Paths.image('characters/$name').replace('png', 'json')));

		this.healthColor = _characterData.healthColor;
		scale.set(_characterData.scale.x, _characterData.scale.y);

		for (animData in _characterData.animationList)
		{
			animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (_characterData.singList.contains(animData.name) && !singList.contains(animData.name)) // do not allow the same animation
				singList[_characterData.singList.indexOf(animData.name)] = animData.name;

			if (_characterData.idleList.contains(animData.name) && !idleList.contains(animData.name))
				idleList[_characterData.idleList.indexOf(animData.name)] = animData.name;

			animOffsets.set(animData.name, new FlxPoint(animData.offset.x, animData.offset.y));
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (animation.curAnim != null)
		{
			if (!isPlayer)
			{
				if (singList.contains(animation.curAnim.name))
				{
					_animationTimer += elapsed;
				}

				var isAbove:Bool = false;

				if (singAnimsUsesMulti)
					isAbove = _animationTimer >= (Conductor.stepCrochet / 1000) * idleDuration;
				else
					isAbove = _animationTimer >= idleDuration;

				if (isAbove)
				{
					dance();
					_animationTimer = 0.0;
				}
			}
		}
	}

	public function dance():Void
	{
		if (idleList.length != 0) // what animations we playing today?
		{
			if (controlIdle)
			{
				_idleIndex = FlxMath.wrap(++_idleIndex, 0, idleList.length - 1);

				playAnim(idleList[_idleIndex]);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(AnimName))
			offsetAnim.set(animOffsets[AnimName].x, animOffsets[AnimName].y);
	}

	override function destroy()
	{
		super.destroy();

		animOffsets = null;
		idleList = null;
	}
}
