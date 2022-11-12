package objects;

// temporary file to easily create stages
import shaders.BuildingShaders;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import objects.handlers.Animation;
import states.PlayState;
import states.PlayState.GameSoundObject;
import music.Song;

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

		stageInstance.camPosList = {
			playerPositions: [],
			spectatorPositions: [],
			opponentPositions: []
		}

		stageInstance.charPosList.playerPositions = [{x: 770, y: 400}];
		stageInstance.charPosList.spectatorPositions = [{x: 400, y: 100}];
		stageInstance.charPosList.opponentPositions = [{x: 100, y: 20}];

		stageInstance.camPosList.playerPositions = [{x: -100, y: -100}];
		stageInstance.camPosList.spectatorPositions = [{x: 0, y: -50}];
		stageInstance.camPosList.opponentPositions = [{x: 100, y: 100}];

		switch (stage)
		{
			case 'spooky':
				{
					stageInstance.charPosList.opponentPositions = [{x: 80, y: 320}];
					stageInstance.charPosList.playerPositions = [{x: 780, y: 440}];
					if (Song.currentSong.opponent == 'monster')
					{
						stageInstance.charPosList.opponentPositions = [{x: 80, y: 190}];
						stageInstance.camPosList.opponentPositions = [{x: 200, y: -120}];
					}
					else
						stageInstance.camPosList.opponentPositions = [{x: 100, y: -100}];

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

					var vignetteFlash:BGSprite = new BGSprite({path: 'vignette', library: 'week2'}, {x: 0, y: 0}, {x: 0, y: 0});
					vignetteFlash.alpha = 0;
					vignetteFlash.setGraphicSize(FlxG.width, FlxG.height);
					vignetteFlash.updateHitbox();
					vignetteFlash.screenCenter();

					vignetteFlash.cameras = [PlayState.current.hudCamera];

					vignetteFlash.ID = 1;
					group.set('vignette', vignetteFlash);

					stageInstance.attributes.set('strikeBeat', 0);
					stageInstance.attributes.set('lightningOffset', 8);
				}
			case 'philly':
				{
					stageInstance.charPosList.playerPositions = [{x: 770, y: 480}];
					stageInstance.charPosList.spectatorPositions = [{x: 430, y: 150}];
					stageInstance.charPosList.opponentPositions = [{x: 100, y: 420}];

					stageInstance.camPosList.opponentPositions = [{x: 230, y: -100}];
					stageInstance.camPosList.playerPositions = [{x: -150, y: -100}];

					var sky:BGSprite = new BGSprite({path: 'sky', library: 'week3'}, {x: -100, y: -90}, {x: 0.1, y: 0.1});
					sky.ID = 0;
					group.set('sky', sky);

					var city:BGSprite = new BGSprite({path: 'city', library: 'week3'}, {x: -10, y: 0}, {x: 0.3, y: 0.3});
					city.scale.set(0.85, 0.85);
					city.updateHitbox();
					city.ID = 1;
					group.set('city', city);

					var window:BGSprite = new BGSprite({path: 'window', library: 'week3'}, {x: -10, y: 0}, {x: 0.3, y: 0.3});
					window.scale.set(0.85, 0.85);
					window.updateHitbox();
					window.ID = 2;
					group.set('window', window);

					var shader:shaders.BuildingShaders = new shaders.BuildingShaders();
					window.shader = shader.shader;
					stageInstance.attributes.set('lightShader', shader);

					var trainPole:BGSprite = new BGSprite({path: 'behindTrain', library: 'week3'}, {x: -40, y: 50}, {x: 0.95, y: 0.95});
					trainPole.ID = 3;
					group.set('trainPole', trainPole);

					var street:BGSprite = new BGSprite({path: 'street', library: 'week3'}, {x: -40, y: 50}, {x: 0.95, y: 0.95});
					street.ID = 4;
					group.set('street', street);

					stageInstance.attributes.set('windowLights', [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633]);
					group['window'].color = FlxG.random.getObject(stageInstance.attributes['windowLights']);
				}
			default:
				{
					stageInstance.defaultZoom = 0.90;

					stageInstance.camPosList.opponentPositions = [{x: 100, y: -100}];

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

	public function update(elapsed:Float)
	{
		switch (name)
		{
			case 'philly':
				{
					attributes['lightShader'].update(1.5 * (Conductor.crochet / 1000) * elapsed);
				}
		}
	}

	public function beatHit(beat:Int)
	{
		switch (name)
		{
			case 'spooky':
				{
					if (FlxG.random.bool(10) && beat > attributes['strikeBeat'] + attributes['lightningOffset'])
					{
						var thunder:GameSoundObject = new GameSoundObject();
						thunder.loadEmbedded(Paths.sound('thunder_' + FlxG.random.int(1, 2), 'week2'));

						thunder.onComplete = function()
						{
							@:privateAccess
							states.PlayState.current.___trackedSoundObjects.splice(states.PlayState.current.___trackedSoundObjects.indexOf(thunder), 1);
							FlxG.sound.list.remove(thunder);
						}
						thunder.play();

						@:privateAccess
						states.PlayState.current.___trackedSoundObjects.push(thunder);

						FlxG.sound.list.add(thunder);

						spriteGroup['halloween'].animation.play('lightning');

						if (Settings.getPref('flashing-lights', true))
						{
							spriteGroup['vignette'].alpha = 1;
							FlxTween.tween(spriteGroup['vignette'], {alpha: 0}, 0.6);
						}

						attributes['strikeBeat'] = beat;
						attributes['lightningOffset'] = FlxG.random.int(8, 24);
					}
				}
			case 'philly':
				{
					if (beat % 4 == 0)
					{
						attributes['lightShader'].reset();
						spriteGroup['window'].color = FlxG.random.getObject(attributes['windowLights']);
					}
				}
		}
	}

	public function countdownTick()
	{
		switch (name)
		{
			case 'mall':
				{}
		}
	}
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

		this.graphicName = image.library + '/' + image.path;

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
