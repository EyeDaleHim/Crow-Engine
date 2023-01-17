package objects;

// temporary file to easily create stages
import shaders.BuildingShaders;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.system.FlxSoundGroup;
import flixel.system.FlxSound;
import flixel.util.typeLimit.OneOfTwo;
import sys.FileSystem;
import objects.handlers.Animation;
import states.PlayState;
import music.Song;

using StringTools;

class Stage
{
	// don't really try to change this, this is just meant as a ref to the sprites
	public static var currentStage:String = '';

	public var defaultZoom:Float = 1.0;
	public var name:String = '';

	public var spriteGroup:Map<String, BGSprite> = [];
	public var stageSoundObjects:Map<String, FlxSound> = [];

	public var charPosList:CharPositions;
	public var camPosList:CharCamPositions;

	public var attributes:Map<String, Dynamic> = [];

	public function new() {}

	public static function getStage(stage:String):Stage
	{
		var group:Map<String, BGSprite> = [];
		var sound:Map<String, FlxSound> = [];

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
					halloween.active = true;
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

					var thunder:FlxSound = new FlxSound();
					thunder.loadEmbedded(Paths.sound('thunder_' + FlxG.random.int(1, 2), 'week2'));

					sound.set('thunder', thunder);

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
					street.ID = 5;
					group.set('street', street);

					var train:BGSprite = new BGSprite({path: 'train', library: 'week3'}, {x: 2000, y: 360}, {x: 1.0, y: 1.0});
					train.ID = 4;
					group.set('train', train);

					stageInstance.attributes.set('windowLights', [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633]);

					var trainSound:FlxSound = new FlxSound();
					trainSound.loadEmbedded(Paths.sound('train_passes', 'week3'));

					sound.set('trainSound', trainSound);

					stageInstance.attributes.set('trainActive', false);

					stageInstance.attributes.set('trainDelay', 0);
					stageInstance.attributes.set('trainDistance', 0);

					stageInstance.attributes.set('movementActive', false);
					stageInstance.attributes.set('trainAmount', 8);

					group['window'].color = FlxG.random.getObject(stageInstance.attributes['windowLights']);
				}
			case 'limo':
				{
					stageInstance.defaultZoom = 0.90;

					stageInstance.charPosList.playerPositions[0].x += 260;
					stageInstance.charPosList.playerPositions[0].y -= 220;

					var sky:BGSprite = new BGSprite({path: 'limoSunset', library: 'week4'}, {x: -120, y: -50}, {x: 0.1, y: 0.1});
					sky.ID = 0;
					group.set('sky', sky);

					var backLimo:BGSprite = new BGSprite({path: 'bgLimo', library: 'week4'}, {x: -200, y: 480}, {x: 0.4, y: 0.4}, [
						{
							name: 'driving',
							prefix: "background limo pink",
							fps: 24,
							looped: true,
							indices: [],
							offset: {x: 0, y: 0}
						}
					]);
					backLimo.active = true;
					backLimo.animation.play('driving');
					backLimo.ID = 1;
					group.set('backgroundLimo', backLimo);

					var limo:BGSprite = new BGSprite({path: 'limoDrive', library: 'week4'}, {x: -120, y: 550}, null, [
						{
							name: 'driving',
							prefix: "Limo stage",
							fps: 24,
							looped: true,
							indices: [],
							offset: {x: 0, y: 0}
						}
					]);
					limo.active = true;
					limo.animation.play('driving');
					limo.ID = 2;
					group.set('limo', limo);

					var car:BGSprite = new BGSprite({path: 'fastCarLol', library: 'week4'}, {x: -300, y: 160});
					car.ID = 3;
					group.set('car', car);

					stageInstance.attributes.set('carActive', false);
					stageInstance.attributes.set('carPassingTime', 0.0);
				}
			case 'mall':
				{
					stageInstance.defaultZoom = 0.80;

					stageInstance.charPosList.playerPositions[0].x += 130;
					stageInstance.charPosList.opponentPositions[0].x -= 500;
					stageInstance.charPosList.opponentPositions[0].y = 70;

					stageInstance.camPosList.playerPositions[0].y -= 100;

					stageInstance.camPosList.opponentPositions[0].y -= 200;
					stageInstance.camPosList.opponentPositions[0].x += 100;

					var bg:BGSprite = new BGSprite({path: 'bgWalls', library: 'week5'}, {x: -1000, y: -500}, {x: 0.2, y: 0.2});
					bg.scale.set(0.8, 0.8);
					bg.updateHitbox();
					bg.ID = 0;
					group.set('background', bg);

					var upBoppers:BGSprite = new BGSprite({path: 'upperBop', library: 'week5'}, {x: -240, y: -90}, {x: 0.33, y: 0.33}, [
						{
							name: 'bop',
							prefix: "Upper Crowd Bob",
							fps: 24,
							looped: false,
							indices: [],
							offset: {x: 0, y: 0}
						}
					]);
					upBoppers.scale.set(0.85, 0.85);
					upBoppers.updateHitbox();
					upBoppers.ID = 1;
					group.set('upBoppers', upBoppers);

					var escalator:BGSprite = new BGSprite({path: 'bgEscalator', library: 'week5'}, {x: -1100, y: -600}, {x: 0.3, y: 0.3});
					escalator.scale.set(0.9, 0.9);
					escalator.updateHitbox();
					escalator.ID = 2;
					group.set('escalator', escalator);

					var tree:BGSprite = new BGSprite({path: 'christmasTree', library: 'week5'}, {x: 370, y: -250}, {x: 0.4, y: 0.4});
					tree.updateHitbox();
					tree.ID = 3;
					group.set('tree', tree);

					var botBoppers:BGSprite = new BGSprite({path: 'bottomBop', library: 'week5'}, {x: -300, y: 140}, {x: 0.9, y: 0.9}, [
						{
							name: 'bop',
							prefix: "Bottom Level Boppers Idle",
							fps: 24,
							looped: false,
							indices: [],
							offset: {x: 0, y: 0}
						}
					]);
					botBoppers.ID = 4;
					group.set('botBoppers', botBoppers);

					var ground:BGSprite = new BGSprite({path: 'fgSnow', library: 'week5'}, {x: -600, y: 700}, {x: 1.0, y: 1.0});
					ground.ID = 5;
					group.set('ground', ground);

					var santa:BGSprite = new BGSprite({path: 'santa', library: 'week5'}, {x: -840, y: 150}, {x: 1.0, y: 1.0}, [
						{
							name: 'idle',
							prefix: 'santa idle in fear',
							fps: 24,
							looped: false,
							indices: [],
							offset: {x: 0, y: 0}
						}
					]);
					santa.renderPriority = 0x01;
					santa.ID = 6;
					group.set('santa', santa);
				}
			case 'red-mall':
				{
					stageInstance.charPosList.playerPositions[0].x += 320;

					var bg:BGSprite = new BGSprite({path: 'evilBG', library: 'week5'}, {x: -400, y: -500}, {x: 0.2, y: 0.2});
					bg.scale.set(0.8, 0.8);
					bg.updateHitbox();
					bg.ID = 0;
					group.set('background', bg);

					var tree:BGSprite = new BGSprite({path: 'evilTree', library: 'week5'}, {x: 300, y: -300}, {x: 0.2, y: 0.2});
					tree.ID = 1;
					group.set('tree', tree);

					var snow:BGSprite = new BGSprite({path: 'evilSnow', library: 'week5'}, {x: -200, y: 700});
					snow.ID = 2;
					group.set('snow', snow);
				}
			case 'warzone':
				{
					stageInstance.defaultZoom = 0.90;

					stageInstance.charPosList.spectatorPositions[0].y += 10;
					stageInstance.charPosList.spectatorPositions[0].x -= 30;

					stageInstance.charPosList.playerPositions[0].x += 40;

					stageInstance.charPosList.opponentPositions[0].y += 300;
					stageInstance.charPosList.opponentPositions[0].x -= 80;

					stageInstance.camPosList.opponentPositions[0].y *= -1;

					var sky:BGSprite = new BGSprite({path: 'sky', library: 'week7'}, {x: -400, y: -400}, {x: 0.0, y: 0.0});
					sky.ID = 0;
					group.set('sky', sky);

					var cloud:BGSprite = new BGSprite({path: 'clouds', library: 'week7'}, {x: FlxG.random.int(-700, -100), y: FlxG.random.int(-20, 20)},
						{x: 0.10, y: 0.10});
					cloud.active = true;
					cloud.ID = 1;
					group.set('clouds', cloud);

					var mountains:BGSprite = new BGSprite({path: 'mountains', library: 'week7'}, {x: -300, y: -20}, {x: 0.20, y: 0.20});
					mountains.scale.set(1.2, 1.2);
					mountains.updateHitbox();
					mountains.ID = 2;
					group.set('mountains', mountains);

					var building:BGSprite = new BGSprite({path: 'buildings', library: 'week7'}, {x: -200, y: 0}, {x: 0.30, y: 0.30});
					building.scale.set(1.1, 1.1);
					building.updateHitbox();
					building.ID = 3;
					group.set('building', building);

					var ruin:BGSprite = new BGSprite({path: 'ruins', library: 'week7'}, {x: -200, y: 0}, {x: 0.35, y: 0.35});
					ruin.scale.set(1.1, 1.1);
					ruin.updateHitbox();
					ruin.ID = 4;
					group.set('ruin', ruin);

					var smokeLeft:BGSprite = new BGSprite({path: 'smokeLeft', library: 'week7'}, {x: -200, y: -100}, {x: 0.4, y: 0.4}, [
						{
							name: 'emitSmoke',
							prefix: 'SmokeBlurLeft',
							indices: [],
							fps: 24,
							looped: true,
							offset: {x: 0, y: 0}
						}
					]);
					smokeLeft.ID = 5;
					smokeLeft.active = true;
					smokeLeft.animation.play('emitSmoke');
					group.set('smokeLeft', smokeLeft);

					var smokeRight:BGSprite = new BGSprite({path: 'smokeRight', library: 'week7'}, {x: 1100, y: -100}, {x: 0.4, y: 0.4}, [
						{
							name: 'emitSmoke',
							prefix: 'SmokeRight',
							indices: [],
							fps: 24,
							looped: true,
							offset: {x: 0, y: 0}
						}
					]);
					smokeRight.ID = 6;
					smokeRight.active = true;
					smokeRight.animation.play('emitSmoke');
					group.set('smokeRight', smokeRight);

					var tankTower:BGSprite = new BGSprite({path: 'watchTower', library: 'week7'}, {x: 100, y: 50}, {x: 0.50, y: 0.50}, [
						{
							name: 'idle',
							prefix: 'watchtower gradient color instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					tankTower.ID = 7;
					tankTower.active = true;
					group.set('tankTower', tankTower);

					var ground:BGSprite = new BGSprite({path: 'ground', library: 'week7'}, {x: -420, y: -150});
					ground.scale.set(1.15, 1.15);
					ground.updateHitbox();
					ground.ID = 8;
					group.set('ground', ground);
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
		stageInstance.stageSoundObjects = sound;

		return stageInstance;
	}

	public function update(elapsed:Float)
	{
		switch (name)
		{
			case 'philly':
				{
					attributes['lightShader'].update(1.5 * (Conductor.crochet / 1000) * elapsed);

					if (attributes['trainActive'])
					{
						if (stageSoundObjects['trainSound'].playing && stageSoundObjects['trainSound'].time >= 4700)
						{
							attributes['movementActive'] = true;

							if (states.PlayState.current.spectator.animation.curAnim.name != 'hairBlow'
								|| states.PlayState.current.spectator.animation.finished)
								states.PlayState.current.spectator.playAnim('hairBlow');
						}

						if (attributes['movementActive'])
						{
							attributes['trainDelay'] += elapsed;

							if (attributes['trainDelay'] >= 1 / 24)
							{
								attributes['trainDelay'] -= 1 / 24;

								spriteGroup['train'].x -= 400;

								if (spriteGroup['train'].x < -2000 && attributes['trainAmount'] > 0)
								{
									spriteGroup['train'].x = -1150;
									attributes['trainAmount'] -= 1;
								}
							}
						}

						if (spriteGroup['train'].x < -4000 && attributes['trainAmount'] <= 0)
						{
							states.PlayState.current.spectator.playAnim('hairFall');

							attributes['trainAmount'] = 8;
							attributes['trainDistance'] = 0;
							attributes['trainActive'] = false;
							attributes['movementActive'] = false;

							spriteGroup['train'].x = 2000;
						}
					}
				}
		}
	}

	public function beatHit(beat:Int)
	{
		switch (name)
		{
			case 'spooky':
				{
					@:privateAccess
					{
						if (FlxG.random.bool(10) && beat > attributes['strikeBeat'] + attributes['lightningOffset'])
						{
							var thunder:FlxSound = stageSoundObjects.get('thunder');
							thunder.onComplete = function()
							{
								states.PlayState.current.___trackedSoundObjects.splice(states.PlayState.current.___trackedSoundObjects.indexOf(thunder), 1);
								FlxG.sound.list.remove(thunder);
							}

							thunder.play();

							states.PlayState.current.___trackedSoundObjects.push(thunder);

							FlxG.sound.list.add(thunder);

							states.PlayState.current.spectator.playAnim('scared');
							states.PlayState.current.player.playAnim('scared');

							spriteGroup['halloween'].animation.play('lightning');

							if (Settings.getPref('flashing-lights', true))
							{
								FlxTween.num(1, 0, 0.6, null, function(v)
								{
									spriteGroup['vignette'].alpha = v;
								});
							}

							attributes['strikeBeat'] = beat;
							attributes['lightningOffset'] = FlxG.random.int(8, 24);
						}
					}
				}
			case 'philly':
				{
					@:privateAccess
					{
						if (beat % 4 == 0)
						{
							attributes['lightShader'].reset();
							spriteGroup['window'].color = FlxG.random.getObject(attributes['windowLights']);
						}

						if (!stageSoundObjects['trainSound'].playing && beat % 2 == 0 && FlxG.random.bool(75))
						{
							if (attributes['trainDistance'] >= 8 && FlxG.random.bool(30))
							{
								attributes['trainActive'] = true;

								@:privateAccess
								{
									states.PlayState.current.___trackedSoundObjects.push(stageSoundObjects['trainSound']);
									FlxG.sound.list.add(stageSoundObjects['trainSound']);

									stageSoundObjects['trainSound'].onComplete = function()
									{
										states.PlayState.current.___trackedSoundObjects.splice(states.PlayState.current.___trackedSoundObjects.indexOf(stageSoundObjects['trainSound']),
											1);
										FlxG.sound.list.remove(stageSoundObjects['trainSound']);
									}
								}

								stageSoundObjects['trainSound'].play(true);
							}

							attributes['trainDistance'] += 1;
						}
					}
				}
			case 'mall':
				{
					spriteGroup['upBoppers'].animation.play('bop', true);
					spriteGroup['botBoppers'].animation.play('bop', true);
					spriteGroup['santa'].animation.play('idle', true);
				}
			case 'warzone':
				{
					if (beat % 2 == 0)
						spriteGroup['tankTower'].animation.play('idle', true);
				}
		}
	}

	public function countdownTick()
	{
		switch (name)
		{
			case 'mall':
				{
					spriteGroup['upBoppers'].animation.play('bop', true);
					spriteGroup['botBoppers'].animation.play('bop', true);
					spriteGroup['santa'].animation.play('idle', true);
				}
			case 'warzone':
				{
					@:privateAccess
					if (Math.abs(cast(FlxG.state, MusicBeatState).curBeat) % 2 == 0)
						spriteGroup['tankTower'].animation.play('idle', true);
				}
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

		if (image.library == null)
			image.library = Paths.currentLibrary;

		super(position.x, position.y);
		scrollFactor.set(scroll.x, scroll.y);
		antialiasing = Settings.getPref('antialiasing', true);

		// prevent black backgrounds and use the stage default if we didn't get
		// the player's stage correctly
		if (image.path.split('/')[0] == 'stage-error')
		{
			image.path = image.path.replace('stage-error', 'stage');
			image.library = 'week1';
		}

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

		active = false;
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
	@:optional var library:Null<String>;
}

typedef SimplePoint =
{
	var x:Float;
	var y:Float;
}
