package objects;

// temporary file to easily create stages
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;
import objects.handlers.Animation;

using StringTools;

class Stage
{
	// don't really try to change this, this is just meant as a ref to the sprites
	public static var currentStage:String = '';

	public var defaultZoom:Float = 1.0;
	public var name:String = '';
	public var spriteGroup:Map<String, BGSprite> = [];
	public var charPosList:CharPositions;
	public var camPosList:CharCamPositions;

	public var attributes:Map<String, Dynamic> = [];

	public function new() {}

	public static function getStage(stage:String):Stage
	{
		var group:Map<String, BGSprite> = [];

		currentStage = stage;

		var stageInstance:Stage = new Stage();

		stageInstance.charPosList = {
			playerPositions: [],
			spectatorPositions: [],
			opponentPositions: []
		}

		switch (stage)
		{
			case 'spooky':
				{
					stageInstance.charPosList.playerPositions = [{x: 770, y: 400}];
					stageInstance.charPosList.spectatorPositions = [{x: 400, y: 430}];
					stageInstance.charPosList.opponentPositions = [{x: 100, y: 400}];

					var halloween:BGSprite = new BGSprite({path: 'halloween_bg', library: 'week2'}, {x: -200, y: -100}, {x: 0.95, y: 0.95}, [
						{
							name: 'idle',
							prefix: 'halloweem bg0',
							indices: [],
							fps: 24,
							looped: true,
							offset: {x: 0, y: 0}
						},
						{
							name: 'lightning',
							prefix: 'halloweem bg lightning strike',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					halloween.ID = 0;
					halloween.animation.play('idle');

					group.set('halloween', halloween);

					stageInstance.attributes.set('strikeBeat', 0);
					stageInstance.attributes.set('lightningOffset', 8);
				}
			default:
				{
					stageInstance.defaultZoom = 0.90;

					stageInstance.charPosList.playerPositions = [{x: 770, y: 400}];
					stageInstance.charPosList.spectatorPositions = [{x: 400, y: 430}];
					stageInstance.charPosList.opponentPositions = [{x: 100, y: 400}];

					var background:BGSprite = new BGSprite({path: 'stageback', library: 'week1'}, {x: -600, y: -200}, {x: 0.9, y: 0.9});
					background.ID = 0;
					group.set('back', background);

					var front:BGSprite = new BGSprite({path: 'stagefront', library: 'week1'}, {x: -650, y: 600}, {x: 0.9, y: 0.9});
					front.scale.set(1.1, 1.1);
					front.updateHitbox();
					front.ID = 1;
					group.set('front', front);

					var curtains:BGSprite = new BGSprite({path: 'stagecurtains', library: 'week1'}, {x: -500, y: -300}, {x: 1.3, y: 1.3});
					curtains.scale.set(0.9, 0.9);
					curtains.updateHitbox();
					curtains.renderPriority = 0x01;
					curtains.ID = 2;
					group.set('curtain', curtains);
				}
		}

		currentStage = '';

		stageInstance.name = stage;
		stageInstance.spriteGroup = group;

		return stageInstance;
	}

	public function update(stage:Stage, elapsed:Float) {}

	public function beatHit(beat:Int)
	{
		switch (name)
		{
			case 'spooky':
				{
					if (FlxG.random.bool(10) && beat > attributes['strikeBeat'] + attributes['lightningOffset'])
					{
						spriteGroup['halloween'].animation.play('lightning');

						attributes['strikeBeat'] = beat;
						attributes['lightningOffset'] = FlxG.random.int(8, 24);
					}
				}
		}
	}

	public function countdownTick(stage:Stage) {}
}

class BGSprite extends FlxSprite
{
	public var graphicName:String = '';
	public var renderPriority:Int = 0x00; // this is literally just to tell you if this sprite wants to be rendered before or after the characters

	public function new(image:ImagePath, ?position:SimplePoint, ?scroll:SimplePoint, ?animArray:Array<Animation> = null)
	{
		if (position == null)
			position = {x: 0.0, y: 0.0};
		if (scroll == null)
			scroll = {x: 1.0, y: 1.0};

		super(position.x, position.y);
		scrollFactor.set(scroll.x, scroll.y);
		antialiasing = Settings.getPref('antialiasing', true);

		this.graphicName = image.library;

		image.path = Stage.currentStage + '/' + image.path;

		if (animArray != null)
		{
			frames = Paths.getSparrowAtlas(image.path, image.library);

			for (anim in animArray)
			{
				animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);
			}
		}
		else
		{
			loadGraphic(Paths.image(image.path, image.library));
		}
	}
}

typedef CharPositions =
{
	var playerPositions:Array<SimplePoint>;
	var spectatorPositions:Array<SimplePoint>;
	var opponentPositions:Array<SimplePoint>;
}

typedef CharCamPositions =
{
	var playerPositions:Array<SimplePoint>;
	var spectatorPositions:Array<SimplePoint>;
	var opponentPositions:Array<SimplePoint>;
}

typedef ImagePath =
{
	var path:String;
	var library:Null<String>;
}

typedef SimplePoint =
{
	var x:Float;
	var y:Float;
}
