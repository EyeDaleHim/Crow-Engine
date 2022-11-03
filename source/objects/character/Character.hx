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

@:allow(states.PlayState)
class Character extends FlxSprite
{
	// basic info
	public var name:String = 'bf';
	public var isPlayer:Bool = true;
	public var healthColor:Int = 0;

	// ok i removed some of the variables because i got lazier over time
	// simple controls for your character
	public var controlIdle:Bool = true; // Whether or not your character should keep playing the idle when it finishes an animation.
	public var forceIdle:Bool = false;
	// public var singAnimsUsesMulti:Bool = false; // If this is enabled, the sing animation will hold for (Conductor.crochet / 1000) * idleDuration, else, it'll just be idleDuration
	public var idleDuration:Float = 0.65; // The amount of seconds (or multiplication) on when the idle animation should be played after the sing animation
	public var overridePlayer:Bool = false; // If you set this to true, the enemy will be treated as a player

	// animation stuff
	public var animOffsets:Map<String, FlxPoint> = [];
	public var idleList:Array<String> = []; // automatically defaults to the character data idle list
	public var missList:Array<String> = [];
	public var singList:Array<String> = [];

	// handled by this class
	private var _idleIndex:Int = 0;
	private var _animationTimer:Float = 0.0;
	private var _characterData:CharacterData;

	public function new(x:Float, y:Float, name:String, isPlayer:Bool)
	{
		super(x, y);

		quickCharacterMaker();

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
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (_characterData.singList.contains(animData.name))
				singList[_characterData.singList.indexOf(animData.name)] = animData.name;

			if (_characterData.idleList.contains(animData.name))
				idleList[_characterData.idleList.indexOf(animData.name)] = animData.name;

			if (_characterData.missList.contains(animData.name))
				missList[_characterData.idleList.indexOf(animData.name)] = animData.name;

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, new FlxPoint(animData.offset.x, animData.offset.y));
		}

		antialiasing = Settings.getPref('antialiasing', true);

		if (idleList.length > 0)
			playAnim(idleList[0]);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (animation.curAnim != null)
		{
			if (!overridePlayer || !isPlayer)
			{
				if (singList.contains(animation.curAnim.name))
					_animationTimer += elapsed;

				var dadVar:Float = name == 'dad' ? 6.1 : 4.0;

				if (_animationTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					dance();
					_animationTimer = 0;
				}
			}
		}
	}

	public function dance(?forcePlay:Bool = false):Void
	{
		if (idleList.length != 0) // what animations we playing today?
		{
			if (forcePlay || controlIdle)
			{
				_idleIndex++;
				_idleIndex = FlxMath.wrap(_idleIndex, 0, idleList.length - 1);

				var animToPlay:String = idleList[_idleIndex];

				playAnim(animToPlay, forceIdle);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(AnimName))
			offsetAnim.set(animOffsets[AnimName].x, animOffsets[AnimName].y);

		offset.set(offsetAnim.x, offsetAnim.y);
	}

	override function destroy()
	{
		super.destroy();

		animOffsets = null;
		idleList = null;
	}

	private function quickCharacterMaker()
	{
		var data:CharacterData;

		var idleList:Array<String> = ['idle'];
		var missList:Array<String> = ['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'];
		var singList:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

		var animationList:Array<Animation> = [];
		var quickAnimAdd:(String, String, Array<Int>, Int, Bool,
			{x:Int, y:Int}) -> Void = function(name:String, prefix:String, indices:Array<Int>, fps:Int, looped:Bool, offset:{x:Int, y:Int})
			{
				animationList.push({
					name: name,
					prefix: prefix,
					indices: indices,
					fps: fps,
					looped: looped,
					offset: offset
				});
			};

		quickAnimAdd('idle', 'Dad idle dance', [], 24, false, {x: 0, y: 0});

		quickAnimAdd('singLEFT', 'Dad LEFT dance', [], 24, false, {x: -10, y: 10});
		quickAnimAdd('singDOWN', 'Dad DOWN dance', [], 24, false, {x: 0, y: -30});
		quickAnimAdd('singUP', 'Dad UP dance', [], 24, false, {x: -6, y: 50});
		quickAnimAdd('singRIGHT', 'Dad RIGHT dance', [], 24, false, {x: 0, y: 27});

		data = {
			name: 'bf',
			healthColor: 0xFFAF66CE,
			animationList: animationList,
			idleList: idleList,
			missList: missList,
			singList: singList,
			scale: {x: 1.0, y: 1.0}
		}

		trace(Json.stringify(data, "\t"));
	}
}
