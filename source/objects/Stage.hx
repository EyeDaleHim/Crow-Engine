package objects;

// temporary file to easily create stages
import shaders.BuildingShaders;
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

	public var charPosList:ListedPosition;
	public var camPosList:ListedPosition;

	public var attributes:Map<String, Dynamic> = [];

	public function new()
	{
	}

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

					if (PlayState.current != null)
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

					stageInstance.camPosList.playerPositions[0].x -= 80;
					stageInstance.camPosList.playerPositions[0].y += 20;

					stageInstance.camPosList.opponentPositions[0].y = stageInstance.camPosList.playerPositions[0].y;

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

					for (i in 0...6)
					{
						var leftIndices:Array<Int> = Tools.numberArray(0, 14);

						var rightIndices:Array<Int> = Tools.numberArray(15, 29);

						var dancer:BGSprite = new BGSprite({path: 'limoDancer', library: 'week4'}, {x: (370 * i) + 170, y: backLimo.y - 400},
							{x: 0.4, y: 0.4}, [
							{
								name: 'danceLeft',
								prefix: 'bg dancer sketch PINK',
								fps: 24,
								indices: leftIndices,
								looped: false,
								offset: {x: 0, y: 0}
							},
							{
								name: 'danceRight',
								prefix: 'bg dancer sketch PINK',
								fps: 24,
								indices: rightIndices,
								looped: false,
								offset: {x: 0, y: 0}
							}
						]);
						dancer.ID = 2 + i;
						dancer.active = true;
						dancer.animation.play('danceLeft');
						dancer.attributes.set('danceDirection', true);
						group.set('dancer$i', dancer);
					}

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
					limo.renderPriority = AFTER_CHAR;
					limo.ID = 7;
					group.set('limo', limo);

					var car:BGSprite = new BGSprite({path: 'fastCarLol', library: 'week4'}, {x: -12600, y: 160});
					car.ID = 8;
					car.active = true;
					group.set('car', car);

					stageInstance.attributes.set('carTime', 14.0);
					stageInstance.attributes.set('carActive', false);
					stageInstance.attributes.set('carPrepare', false);
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
					upBoppers.active = true;
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
					botBoppers.active = true;
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
					santa.renderPriority = AFTER_CHAR;
					santa.ID = 6;
					santa.active = true;
					group.set('santa', santa);
				}
			case 'red-mall':
				{
					stageInstance.charPosList.playerPositions[0].x += 320;

					stageInstance.charPosList.opponentPositions[0].x = 70;
					stageInstance.charPosList.opponentPositions[0].y = 150;

					stageInstance.camPosList.opponentPositions[0].x = 200;
					stageInstance.camPosList.opponentPositions[0].y = -90;

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
			case 'school':
				{
					stageInstance.charPosList.playerPositions[0].x = 970;
					stageInstance.charPosList.playerPositions[0].y = 670;

					stageInstance.charPosList.opponentPositions[0].x = 250;
					stageInstance.charPosList.opponentPositions[0].y = 460;

					stageInstance.charPosList.spectatorPositions[0].x = 550;
					stageInstance.charPosList.spectatorPositions[0].y = 500;

					stageInstance.camPosList.opponentPositions[0].y = 0;
					stageInstance.camPosList.opponentPositions[0].x += 50;

					var sky:BGSprite = new BGSprite({path: 'sky', library: 'week6'}, {x: 0, y: 0}, {x: 0, y: 0});
					var widthData = Std.int(sky.width * 6);
					sky.antialiasing = false;
					sky.setGraphicSize(widthData);
					sky.updateHitbox();
					sky.ID = 0;
					group.set('sky', sky);

					var school:BGSprite = new BGSprite({path: 'school', library: 'week6'}, {x: -260, y: 0}, {x: 0.6, y: 0.9});
					school.antialiasing = false;
					school.setGraphicSize(widthData);
					school.updateHitbox();
					school.ID = 1;
					group.set('school', school);

					var street:BGSprite = new BGSprite({path: 'street', library: 'week6'}, {x: -200, y: 0}, {x: 0.95, y: 0.95});
					street.antialiasing = false;
					street.setGraphicSize(widthData);
					street.updateHitbox();
					street.ID = 2;
					group.set('street', street);

					var bgTrees:BGSprite = new BGSprite({path: 'treesBack', library: 'week6'}, {x: -30, y: 130}, {x: 0.9, y: 0.9});
					bgTrees.antialiasing = false;
					bgTrees.setGraphicSize(widthData * 0.8);
					bgTrees.updateHitbox();
					bgTrees.ID = 3;
					group.set('bgTrees', bgTrees);

					var fgTrees:BGSprite = new BGSprite({path: 'trees', library: 'week6'}, {x: -1480, y: -1600}, {x: 0.9, y: 0.9}, [
						{
							name: 'sway',
							prefix: 'trees_',
							fps: 12,
							offset: {x: 0, y: 0},
							looped: true,
							indices: [],
							atlas: 'packer'
						}
					]);
					fgTrees.antialiasing = false;
					fgTrees.scale.set(8.4, 8.4);
					fgTrees.updateHitbox();
					fgTrees.animation.play('sway', true);
					fgTrees.active = true;
					fgTrees.ID = 4;
					group.set('fgTrees', fgTrees);

					var petals:BGSprite = new BGSprite({path: 'petals', library: 'week6'}, {x: -200, y: -40}, {x: 0.85, y: 0.85}, [
						{
							name: 'petal',
							prefix: 'PETALS ALL',
							fps: 24,
							offset: {x: 0, y: 0},
							looped: true,
							indices: []
						}
					]);
					petals.antialiasing = false;
					petals.scale.set(6, 6);
					petals.updateHitbox();
					petals.active = true;
					petals.animation.play('petal', true);
					petals.ID = 5;
					group.set('petals', petals);
					var animArray:Array<StageAnimation> = [
						{
							name: 'danceLeft',
							prefix: 'BG girls group',
							fps: 24,
							offset: {x: 0, y: 0},
							indices: Tools.numberArray(0, 13),
							looped: true
						},
						{
							name: 'danceRight',
							prefix: 'BG girls group',
							fps: 24,
							offset: {x: 0, y: 0},
							indices: Tools.numberArray(14, 29),
							looped: true
						}
					];

					if (Song.currentSong.song.formatToReadable() == 'roses')
					{
						animArray = [
							{
								name: 'danceLeft',
								prefix: 'BG fangirls dissuaded',
								fps: 24,
								offset: {x: 0, y: 0},
								indices: Tools.numberArray(0, 13),
								looped: true
							},
							{
								name: 'danceRight',
								prefix: 'BG fangirls dissuaded',
								fps: 24,
								offset: {x: 0, y: 0},
								indices: Tools.numberArray(14, 29),
								looped: true
							}
						];
					}

					var bgGirls:BGSprite = new BGSprite({path: 'bgFreaks', library: 'week6'}, {x: -100, y: 440}, {x: 0.9, y: 0.9}, animArray);
					bgGirls.scale.set(6, 6);
					bgGirls.antialiasing = false;
					bgGirls.ID = 6;
					bgGirls.active = true;
					bgGirls.animation.play('danceLeft', true);
					bgGirls.attributes.set('danceDirection', true);
					group.set('bgGirls', bgGirls);
				}
			case 'dark-school':
				{
					stageInstance.charPosList.playerPositions[0].x = 970;
					stageInstance.charPosList.playerPositions[0].y = 640;

					stageInstance.charPosList.spectatorPositions[0].x = 580;
					stageInstance.charPosList.spectatorPositions[0].y = 430;

					stageInstance.charPosList.opponentPositions[0].x = 140;
					stageInstance.charPosList.opponentPositions[0].y = 340;

					stageInstance.camPosList.opponentPositions[0].x = 150;
					stageInstance.camPosList.opponentPositions[0].y = 0;

					var school:BGSprite = new BGSprite({path: 'animatedEvilSchool', library: 'week6'}, {x: 400, y: 200}, {x: 0.80, y: 0.90}, [{
						name: 'idle',
						prefix: 'background 2',
						fps: 24,
						offset: {x: 0, y: 0},
						indices: [],
						looped: true
					}]);
					school.scale.set(6 ,6);
					school.active = true;
					school.ID = 0;
					school.antialiasing = false;
					school.animation.play('idle', true);
					group.set('school', school);
				}
			case 'warzone':
				{
					stageInstance.defaultZoom = 0.90;

					stageInstance.charPosList.spectatorPositions[0].y = 110;
					stageInstance.charPosList.spectatorPositions[0].x = 270;

					stageInstance.charPosList.playerPositions[0].x += 40;
					stageInstance.charPosList.playerPositions[0].y += 90;

					stageInstance.charPosList.opponentPositions[0].y += 300;
					stageInstance.charPosList.opponentPositions[0].x -= 80;

					stageInstance.camPosList.opponentPositions[0].y *= -1;
					stageInstance.camPosList.opponentPositions[0].y += 20;

					stageInstance.camPosList.playerPositions[0].y = -130;

					if (Song.currentSong.spectator == 'picoSpeaker')
						stageInstance.charPosList.spectatorPositions[0].y = -10;

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

					var tank:BGSprite = new BGSprite({path: 'tank', library: 'week7'}, {x: 300, y: 300}, {x: 0.5, y: 0.5}, [
						{
							name: 'idle',
							prefix: 'BG tank w lighting instance 1',
							indices: [],
							fps: 24,
							looped: true,
							offset: {x: 0, y: 0}
						}
					]);
					tank.active = true;
					tank.animation.play('idle');
					tank.ID = 8;
					group.set('tank', tank);

					var ground:BGSprite = new BGSprite({path: 'ground', library: 'week7'}, {x: -420, y: -150});
					ground.scale.set(1.15, 1.15);
					ground.updateHitbox();
					ground.ID = 9;
					group.set('ground', ground);

					var audienceList:Array<BGSprite> = [];
					stageInstance.attributes.set('audienceList', audienceList);

					var fgTank0:BGSprite = new BGSprite({path: 'audience/tank0', library: 'week7'}, {x: -500, y: 650}, {x: 1.7, y: 1.5}, [
						{
							name: 'idle',
							prefix: 'fg tankhead far right instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank0.active = true;
					fgTank0.ID = 10;
					fgTank0.renderPriority = AFTER_CHAR;
					group.set('tank0', fgTank0);

					var fgTank1:BGSprite = new BGSprite({path: 'audience/tank1', library: 'week7'}, {x: -300, y: 750}, {x: 2.0, y: 0.2}, [
						{
							name: 'idle',
							prefix: 'fg tankhead 5 instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank1.active = true;
					fgTank1.ID = 11;
					fgTank1.renderPriority = AFTER_CHAR;
					group.set('tank1', fgTank1);

					var fgTank2:BGSprite = new BGSprite({path: 'audience/tank2', library: 'week7'}, {x: 450, y: 940}, {x: 1.5, y: 1.5}, [
						{
							name: 'idle',
							prefix: 'foreground man 3 instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank2.active = true;
					fgTank2.ID = 12;
					fgTank2.renderPriority = AFTER_CHAR;
					group.set('tank2', fgTank2);

					var fgTank3:BGSprite = new BGSprite({path: 'audience/tank3', library: 'week7'}, {x: 1300, y: 1200}, {x: 3.5, y: 2.5}, [
						{
							name: 'idle',
							prefix: 'fg tankhead 4 instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank3.active = true;
					fgTank3.ID = 15;
					fgTank3.renderPriority = AFTER_CHAR;
					group.set('tank3', fgTank3);

					var fgTank4:BGSprite = new BGSprite({path: 'audience/tank4', library: 'week7'}, {x: 1300, y: 900}, {x: 1.5, y: 1.5}, [
						{
							name: 'idle',
							prefix: 'fg tankman bobbin 3 instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank4.active = true;
					fgTank4.ID = 13;
					fgTank4.renderPriority = AFTER_CHAR;
					group.set('tank4', fgTank4);

					var fgTank5:BGSprite = new BGSprite({path: 'audience/tank5', library: 'week7'}, {x: 1620, y: 700}, {x: 1.5, y: 1.5}, [
						{
							name: 'idle',
							prefix: 'fg tankhead far right instance 1',
							indices: [],
							fps: 24,
							looped: false,
							offset: {x: 0, y: 0}
						}
					]);
					fgTank5.active = true;
					fgTank5.ID = 14;
					fgTank5.renderPriority = AFTER_CHAR;
					group.set('tank5', fgTank5);

					stageInstance.attributes.set('tankAngle', FlxG.random.int(-90, 45));
					stageInstance.attributes.set('tankSpeed', FlxG.random.float(5, 7));
				}
			case 'backalley':
					{
						stageInstance.defaultZoom = 0.90;
	
						stageInstance.camPosList.opponentPositions = [{x: 100, y: -100}];
	
						var background:BGSprite = new BGSprite({path: 'whittyBack', library: 'backalley'}, {x: -600, y: -200}, {x: 0.9, y: 0.9});
						background.ID = 0;
						group.set('back', background);
	
						var front:BGSprite = new BGSprite({path: 'whittyFront', library: 'backalley'}, {x: -650, y: 600}, {x: 0.9, y: 0.9});
						front.scale.set(1.1, 1.1);
						front.updateHitbox();
						front.ID = 1;
						group.set('front', front);
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
					curtains.renderPriority = AFTER_CHAR;
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
							states.PlayState.current.spectator.playAnim('hairFall', true);

							states.PlayState.current.spectator.controlIdle = false;
							states.PlayState.current.spectator.animation.finishCallback = function(name:String)
							{
								states.PlayState.current.spectator.controlIdle = true;
								states.PlayState.current.spectator.animation.finishCallback = null;
							}

							attributes['trainAmount'] = 8;
							attributes['trainDistance'] = 0;
							attributes['trainActive'] = false;
							attributes['movementActive'] = false;

							spriteGroup['train'].x = 2000;
						}
					}
				}
			case 'limo':
				{
					if (!attributes['carActive'])
					{
						if (attributes['carPrepare'])
							attributes.set('carActive', FlxG.random.bool(10));
						else if (attributes['carTime'] >= 0.0)
							attributes['carTime'] -= elapsed;
						else
							attributes.set('carPrepare', true);
					}
					else
					{
						spriteGroup['car'].x = -12600;
						spriteGroup['car'].y = FlxG.random.int(140, 250);

						FlxG.sound.play(Paths.sound('carPass' + FlxG.random.int(0, 1)), 0.7);

						spriteGroup['car'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;

						attributes.set('carActive', false);
						attributes.set('carPrepare', false);
						attributes.set('carTime', FlxG.random.float(12, 28));
					}

					if (spriteGroup['car'].x > FlxG.width * 4)
						spriteGroup['car'].velocity.x = 0.0;
				}
			case 'warzone':
				{
					if (states.PlayState.current.cutsceneHandler == null || states.PlayState.current.cutsceneHandler.cutsceneFinished)
						attributes['tankAngle'] += elapsed * attributes['tankSpeed'];

					spriteGroup['tank'].angle = attributes['tankAngle'] - 90 + 15;
					spriteGroup['tank'].x = 400 + (1500 * Math.cos(Math.PI / 180 * (1 * attributes['tankAngle'] + 180)));
					spriteGroup['tank'].y = 1300 + (1100 * Math.sin(Math.PI / 180 * (1 * attributes['tankAngle'] + 180)));
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
							spriteGroup['vignette'].cameras = [PlayState.current.hudCamera];

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
			case 'limo':
				{
					for (i in 0...6)
					{
						if (spriteGroup['dancer$i'].attributes['danceDirection'])
							spriteGroup['dancer$i'].animation.play('danceRight', true);
						else
							spriteGroup['dancer$i'].animation.play('danceLeft', true);

						spriteGroup['dancer$i'].attributes.set('danceDirection', !spriteGroup['dancer$i'].attributes['danceDirection']);
					}
				}
			case 'mall':
				{
					spriteGroup['upBoppers'].animation.play('bop', true);
					spriteGroup['botBoppers'].animation.play('bop', true);
					spriteGroup['santa'].animation.play('idle', true);
				}
			case 'school':
				{
					if (spriteGroup['bgGirls'].attributes['danceDirection'])
						spriteGroup['bgGirls'].animation.play('danceRight', true);
					else
						spriteGroup['bgGirls'].animation.play('danceLeft', true);

					spriteGroup['bgGirls'].attributes.set('danceDirection', !spriteGroup['bgGirls'].attributes['danceDirection']);
				}
			case 'warzone':
				{
					if (beat % 2 == 0)
						spriteGroup['tankTower'].animation.play('idle', true);

					for (i in 0...6)
					{
						if (spriteGroup.exists('tank$i'))
							spriteGroup['tank$i'].animation.play('idle');
					}
				}
		}
	}

	public function countdownTick()
	{
		switch (name)
		{
			case 'limo':
				{
					for (i in 0...6)
					{
						if (spriteGroup['dancer$i'].attributes['danceDirection'])
							spriteGroup['dancer$i'].animation.play('danceRight', true);
						else
							spriteGroup['dancer$i'].animation.play('danceLeft', true);

						spriteGroup['dancer$i'].attributes.set('danceDirection', !spriteGroup['dancer$i'].attributes['danceDirection']);
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
	public var renderPriority:RenderPriority = BEFORE_CHAR; // this is literally just to tell you if this sprite wants to be rendered before or after the characters

	public function new(image:Null<ImagePath>, ?position:SimplePoint, ?scroll:SimplePoint, ?animArray:Array<StageAnimation> = null)
	{
		if (position == null)
			position = {x: 0.0, y: 0.0};
		if (scroll == null)
			scroll = {x: 1.0, y: 1.0};

		if (image == null)
		{
			super();
		}
		else
		{
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
				frames = switch (animArray[0].atlas)
				{
					case 'packer':
						Paths.getPackerAtlas(image.path, image.library);
					default:
						Paths.getSparrowAtlas(image.path, image.library);
				}

				for (anim in animArray)
				{
					if (anim.indices.length > 0)
						animation.addByIndices(anim.name, anim.prefix, anim.indices, "", anim.fps, anim.looped);
					else
						animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);
				}
			}
			else
			{
				loadGraphic(Paths.image(image.path, image.library));
			}
		}

		active = false;
		moves = false;
	}
}

enum abstract RenderPriority(Int)
{
	var BEFORE_CHAR:RenderPriority = 0;
	var AFTER_CHAR:RenderPriority = 1;
}

typedef ListedPosition =
{
	var playerPositions:Array<SimplePoint>;
	var spectatorPositions:Array<SimplePoint>;
	var opponentPositions:Array<SimplePoint>;
}

typedef StageAnimation = Animation &
{
	@:optional var atlas:String;
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
