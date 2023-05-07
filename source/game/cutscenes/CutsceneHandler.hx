package game.cutscenes;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import backend.graphic.CacheManager;
import objects.character.CharacterAnimate;
import states.PlayState;

class CutsceneHandler
{
	public static final cutsceneList:Array<String> = ['winter-horrorland', 'eggnog', 'ugh', 'guns', 'stress'];

	public var time:Float = 0.0;
	public var endTime:Float = 0.0;
	public var cutscene:String;

	public var endCallback:Void->Void = null;
	public var cutsceneFinished:Bool = false;

	public var cutsceneActions:Array<CutsceneAction> = [];
	public var lockedUpdateLoops:Map<String, Void->Void> = [];

	public function new(cutscene:String)
	{
		this.cutscene = cutscene.split('-cutscene-')[0];

		if (cutscene.split('-cutscene-').length == 1)
			cutscene += '-cutscene-start';

		trace('starting ${cutscene}');

		switch (cutscene.split('-cutscene-')[0])
		{
			case 'eggnog':
				{
					if (cutscene.split('-cutscene-')[1] == 'end')
					{
						FlxG.sound.play(Paths.sound('Lights_Shut_off'), 0.8);

						endTime = 1.8;

						cutsceneActions.push({
							action: function()
							{
								FlxG.camera.visible = false;
								PlayState.current.hudCamera.visible = false;
							},
							time: 0.0
						});
					}
				}
			case 'winter-horrorland':
				{
					if (cutscene.split('-cutscene-')[1] == 'start')
					{
						FlxG.sound.play(Paths.sound('Lights_Turn_On'), 0.6);
						FlxG.sound.music.pause();

						endTime = 3.5;

						var tree:FlxSprite = PlayState.current.stageData.spriteGroup['tree'];

						snapCamera(tree.getMidpoint().x, (tree.y - 1250));

						cutsceneActions.push({
							action: function()
							{
								FlxG.camera.zoom = 1.5;
							},
							time: 0.0
						});

						cutsceneActions.push({
							action: function()
							{
								FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue']}, 2.0, {ease: FlxEase.quintInOut});
							},
							time: 1.0
						});
					}
				}
			case 'ugh':
				{
					if (cutscene.split('-cutscene-')[1] == 'start')
					{
						@:privateAccess
						{
							lockedUpdateLoops.set('lockCharUpdate', function()
							{
								PlayState.current.player._animationTimer = 0.0;
								PlayState.current.spectator._animationTimer = 0.0;
								PlayState.current.opponent._animationTimer = 0.0;
							});

							FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0);
							FlxG.sound.music.fadeIn(5, 0, 0.5);

							var savedSounds:Map<String, FlxSound> = [];
							var listOfSounds:Array<{name:String, file:String}> = [
								{name: 'well', file: 'wellWellWell'},
								{name: 'beep', file: 'bfBeep'},
								{name: 'kill_you', file: 'killYou'}
							];

							for (sound in listOfSounds)
							{
								savedSounds.set(sound.name, FlxG.sound.load(Paths.sound('cutscenes/ugh/${sound.file}')));
								savedSounds[sound.name].onComplete = function()
								{
									FlxG.sound.list.remove(savedSounds[sound.name]);
									savedSounds[sound.name].destroy();
									savedSounds.remove(sound.name);
								};

								FlxG.sound.list.add(savedSounds[sound.name]);
							}

							PlayState.current.hudCamera.alpha = 0.0;
							FlxG.camera.zoom *= 1.2;

							var opponent = PlayState.current.opponent;
							opponent.flipX = !opponent.flipX;

							var tankmanTalking:FlxAtlasFrames = Paths.getSparrowAtlas('cutscenes/ugh/tankman');

							endTime = 12;

							var newPos:FlxPoint = FlxPoint.get();
							Tools.transformSimplePoint(newPos, PlayState.current.stageData.camPosList.opponentPositions[0]);

							var midPoint:FlxPoint = opponent.getMidpoint();
							var calculatedPosition:FlxPoint = FlxPoint.get(midPoint.x + newPos.x, midPoint.y + newPos.y);

							snapCamera(calculatedPosition.x, calculatedPosition.y);

							opponent.frames = tankmanTalking;

							opponent.animation.addByPrefix('well', 'TANK TALK 1 P1', 24, false);
							opponent.animation.addByPrefix('should_just', 'TANK TALK 1 P2', 24, false);

							cutsceneActions.push({
								action: function()
								{
									opponent.animation.play('well', true);
									savedSounds['well'].play(true);
								},
								time: 0.1
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x + 550, y: calculatedPosition.y + 80}, 1.1, {
										ease: FlxEase.quintOut,
										onUpdate: function(twn:FlxTween)
										{
											snapCamera(calculatedPosition.x, calculatedPosition.y);
										}
									});
								},
								time: 3.0
							});

							cutsceneActions.push({
								action: function()
								{
									var player = PlayState.current.player;

									savedSounds['beep'].play(true);
									player.playAnim('singUP', true);
									new FlxTimer().start(0.75, function(tmr:FlxTimer)
									{
										player.playAnim('idle', true);
									});
								},
								time: 4.5
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x - 550, y: calculatedPosition.y - 80}, 1.1, {
										ease: FlxEase.quintOut,
										onUpdate: function(twn:FlxTween)
										{
											snapCamera(calculatedPosition.x, calculatedPosition.y);
										}
									});

									opponent.animation.play('should_just', true);
									savedSounds['kill_you'].play(true);
								},
								time: 6
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue']}, 1.0, {ease: FlxEase.quintOut});
									FlxTween.tween(PlayState.current.hudCamera, {alpha: 1.0}, 0.4, {ease: FlxEase.quadInOut});

									opponent.frames = Paths.getSparrowAtlas('characters/${opponent.name}/${opponent.name}');
									opponent.flipX = !opponent.flipX;
									opponent.setupCharacter();
									opponent.animation.play('idle', true);
								},
								time: 11.9
							});
						}
					}
				}
			case 'guns':
				{
					@:privateAccess
					{
						if (cutscene.split('-cutscene-')[1] == 'start')
						{
							lockedUpdateLoops.set('lockCharUpdate', function()
							{
								PlayState.current.player._animationTimer = 0.0;
								PlayState.current.spectator._animationTimer = 0.0;
								PlayState.current.opponent._animationTimer = 0.0;
							});

							FlxG.sound.playMusic(Paths.music('DISTORTO', 'week7'), 0);
							FlxG.sound.music.fadeIn(5, 0, 0.5);

							var savedSounds:Map<String, FlxSound> = [];
							var listOfSounds:Array<{name:String, file:String}> = [{name: 'tightBars', file: 'tightBars'}];

							for (sound in listOfSounds)
							{
								savedSounds.set(sound.name, FlxG.sound.load(Paths.sound('cutscenes/guns/${sound.file}')));
								savedSounds[sound.name].onComplete = function()
								{
									FlxG.sound.list.remove(savedSounds[sound.name]);
									savedSounds[sound.name].destroy();
									savedSounds.remove(sound.name);
								};

								FlxG.sound.list.add(savedSounds[sound.name]);
							}

							PlayState.current.hudCamera.alpha = 0.0;
							// FlxG.camera.zoom *= 1.2;

							var opponent = PlayState.current.opponent;
							opponent.flipX = !opponent.flipX;

							var tankmanTalking:FlxAtlasFrames = Paths.getSparrowAtlas('cutscenes/guns/tankman');

							endTime = 11.6;

							var newPos:FlxPoint = FlxPoint.get();
							Tools.transformSimplePoint(newPos, PlayState.current.stageData.camPosList.opponentPositions[0]);

							newPos.subtract(60, 40);

							var midPoint:FlxPoint = opponent.getMidpoint();
							var calculatedPosition:FlxPoint = FlxPoint.get(midPoint.x + newPos.x, midPoint.y + newPos.y);

							snapCamera(calculatedPosition.x, calculatedPosition.y);

							opponent.frames = tankmanTalking;

							var zoomClosely:FlxTween;

							opponent.animation.addByPrefix('bars', 'TANK TALK 2', 24, false);
							cutsceneActions.push({
								action: function()
								{
									opponent.animation.play('bars', true);
									opponent.offset.set(-40, -10);

									savedSounds['tightBars'].play(true);

									zoomClosely = FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.2 * 1.2}, 6, {ease: FlxEase.quadIn});
								},
								time: 0.1
							});

							cutsceneActions.push({
								action: function()
								{
									zoomClosely.cancel();
									zoomClosely.destroy();
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue'] * 1.2 * 1.2}, 0.3, {
										ease: FlxEase.quintOut,
										onComplete: function(twn:FlxTween)
										{
											FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue'] * 1.2}, 3.5 + 0.2,
												{ease: FlxEase.quadInOut});
										}
									});

									PlayState.current.spectator.animation.finishCallback = function(anim:String)
									{
										PlayState.current.spectator.playAnim('sad', true);
									};

									PlayState.current.spectator.playAnim('sad', true);
								},
								time: 4.2
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue']}, 1.0, {ease: FlxEase.quintOut});
									FlxTween.tween(PlayState.current.hudCamera, {alpha: 1.0}, 0.4, {ease: FlxEase.quadInOut});

									opponent.frames = Paths.getSparrowAtlas('characters/${opponent.name}/${opponent.name}');
									opponent.flipX = !opponent.flipX;
									opponent.setupCharacter();
									opponent.animation.play('idle', true);

									PlayState.current.spectator.animation.finishCallback = null;
								},
								time: 11.5
							});
						}
					}
				}
			case 'stress':
				{
					@:privateAccess
					{
						if (cutscene.split('-cutscene-')[1] == 'start')
						{
							lockedUpdateLoops.set('lockCharUpdate', function()
							{
								PlayState.current.player._animationTimer = 0.0;
								PlayState.current.spectator._animationTimer = 0.0;
								PlayState.current.opponent._animationTimer = 0.0;
							});

							var savedSounds:Map<String, FlxSound> = [];
							var listOfSounds:Array<{name:String, file:String}> = [{name: 'stressCutscene', file: 'stressCutscene'}];

							for (sound in listOfSounds)
							{
								savedSounds.set(sound.name, FlxG.sound.load(Paths.sound('cutscenes/stress/${sound.file}')));
								savedSounds[sound.name].onComplete = function()
								{
									FlxG.sound.list.remove(savedSounds[sound.name]);
									savedSounds[sound.name].destroy();
									savedSounds.remove(sound.name);
								};

								FlxG.sound.list.add(savedSounds[sound.name]);
							}

							PlayState.current.hudCamera.alpha = 0.0;
							// FlxG.camera.zoom *= 1.2;

							var player = PlayState.current.player;
							var spectator = PlayState.current.spectator;
							var opponent = PlayState.current.opponent;

							spectator.y += 100;

							opponent.flipX = !opponent.flipX;

							var tankmanTalking:FlxAtlasFrames = Paths.getSparrowAtlas('cutscenes/stress/tankman1'); // god effing dammit
							var tankmanTalking2:FlxAtlasFrames = Paths.getSparrowAtlas('cutscenes/stress/tankman2'); // look who it is

							var gfDemonEye:FlxAtlasFrames = Paths.getSparrowAtlas('cutscenes/stress/stressGF'); // GLOWWWWW

							var dancingGf:FlxAtlasFrames = Paths.getSparrowAtlas('characters/gf-tankmen/gf-tankmen');
							spectator.frames = dancingGf;

							spectator.animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
								"", 24, false);
							spectator.animation.addByIndices('danceRight', 'GF Dancing at Gunpoint',
								[15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

							var picoAppear:CharacterAnimate = new CharacterAnimate(410, 435, 'picoKill', 'cutscenes/stress');
							picoAppear.scrollFactor.set(0.95, 0.95);
							picoAppear.addAnim('anim', 'Pico Saves them sequence', 24, false);
							picoAppear.playAnim('anim', true);
							picoAppear.anim.stop();
							picoAppear.visible = false;

							PlayState.current.insert(PlayState.current.members.indexOf(spectator), picoAppear);

							endTime = 35.6;

							var newPos:FlxPoint = FlxPoint.get();
							Tools.transformSimplePoint(newPos, PlayState.current.stageData.camPosList.opponentPositions[0]);

							newPos.add(50, 20);

							var midPoint:FlxPoint = opponent.getMidpoint();
							var calculatedPosition:FlxPoint = FlxPoint.get(midPoint.x + newPos.x, midPoint.y + newPos.y);

							snapCamera(calculatedPosition.x, calculatedPosition.y);

							opponent.frames = tankmanTalking;

							opponent.animation.addByPrefix('effing', 'TANK TALK 3 P1 UNCUT', 24, false);

							spectator.playAnim('danceLeft', true);
							spectator.offset.x += 80; // fuck you

							spectator.animation.finishCallback = function(name:String)
							{
								if (name == 'danceLeft')
									spectator.playAnim('danceRight', true);
								else
									spectator.playAnim('danceLeft', true);

								spectator.offset.x += 80;
							};

							cutsceneActions.push({
								action: function()
								{
									opponent.animation.play('effing', true);
									opponent.offset.set(54, 14);

									savedSounds['stressCutscene'].play(true);
								},
								time: 0.1
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x - 40, y: calculatedPosition.y - 10}, 5, {
										ease: FlxEase.cubeInOut,
										onUpdate: function(twn:FlxTween)
										{
											snapCamera(calculatedPosition.x, calculatedPosition.y);
										}
									});

									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.05}, 6, {ease: FlxEase.quadInOut});
								},
								time: 0.4
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.3}, 2.1, {
										ease: FlxEase.quadInOut
									});

									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x + 200, y: calculatedPosition.y - 170}, 1.0, {
										ease: FlxEase.cubeInOut,
										onUpdate: function(twn:FlxTween)
										{
											snapCamera(calculatedPosition.x, calculatedPosition.y);
										}
									});

									spectator.frames = gfDemonEye;
									spectator.animation.addByPrefix('turn', 'GF STARTS TO TURN PART 1', 24, false);
									spectator.animation.addByPrefix('kill', 'GF STARTS TO TURN PART 2', 24, false);

									spectator.animation.finishCallback = function(name:String)
									{
										switch (name)
										{
											case 'turn':
												{
													spectator.animation.play('kill');
													spectator.offset.set(224 + 80, 440);
												}
											default:
												{
													picoAppear.playAnim('anim', true);
													picoAppear.visible = true;

													spectator.visible = false;

													spectator.animation.finishCallback = null;
												}
										}
									};

									spectator.animation.play('turn', true);
								},
								time: 15.1
							});

							cutsceneActions.push({
								action: function()
								{
									FlxG.camera.zoom = FlxG.camera.attributes['zoomLerpValue'];
								},
								time: 17.6
							});

							cutsceneActions.push({
								action: function()
								{
									opponent.frames = tankmanTalking2;
									opponent.animation.addByPrefix('lookwho', 'TANK TALK 3 P2 UNCUT', 24, false);
									opponent.offset.set(-30);
									opponent.animation.play('lookwho', true);
								},
								time: 19.3
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom * 1.05}, 2.0, {
										ease: FlxEase.quadInOut
									});

									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x - 200, y: calculatedPosition.y + 170}, 2.5, {
										ease: FlxEase.cubeInOut,
										onUpdate: function(twn:FlxTween)
										{
											snapCamera(calculatedPosition.x, calculatedPosition.y);
										}
									});
								},
								time: 20.1
							});

							cutsceneActions.push({
								action: function()
								{
									spectator.frames = Paths.getSparrowAtlas('characters/${spectator.name}/${spectator.name}');
									spectator.setupCharacter();
									spectator.visible = true;
									spectator.playAnim('shoot1-hair_loop', true);
									spectator.y -= 100;

									picoAppear.destroy();
								},
								time: 23.7
							});

							cutsceneActions.push({
								action: function()
								{
									states.PlayState.current.stageData.spriteGroup['tank3'].visible = false;

									player.playAnim('singUPmiss', true);

									player.animation.finishCallback = function(name:String)
									{
										if (name == 'singUPmiss')
										{
											player.playAnim('idle', true);
											player.animation.curAnim.finish();
										}
									};

									snapCamera(player.getMidpoint().x, player.getMidpoint().y - 50);
									FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
								},
								time: 31.3
							});

							cutsceneActions.push({
								action: function()
								{
									states.PlayState.current.stageData.spriteGroup['tank3'].visible = true;
									FlxG.camera.zoom = FlxG.camera.attributes['zoomLerpValue'] * 1.2;

									snapCamera(calculatedPosition.x + 60, calculatedPosition.y + 10);
								},
								time: 32.3
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue']}, 1.0, {ease: FlxEase.quintOut});
									FlxTween.tween(PlayState.current.hudCamera, {alpha: 1.0}, 0.4, {ease: FlxEase.quadInOut});

									opponent.frames = Paths.getSparrowAtlas('characters/${opponent.name}/${opponent.name}');
									opponent.flipX = !opponent.flipX;
									opponent.setupCharacter();
									opponent.animation.play('idle', true);

									PlayState.current.spectator.animation.finishCallback = function(name:String)
									{
										if (PlayState.current.spectator.animation.getByName(name + '-hair_loop') != null)
											PlayState.current.spectator.playAnim(name + '-hair_loop', true);
									}

									var clearCacheList:Array<String> = [
										"assets/images/cutscenes/stress/tankman1.png",
										"assets/images/cutscenes/stress/tankman2.png",
										"assets/images/cutscenes/stress/picoKill/spritemap1.png",
										"assets/images/cutscenes/stress/stressGF.png"
									];

									for (cache in clearCacheList)
										CacheManager.clearBitmap(cache);
								},
								time: 35.5
							});
						}
					}
				}
		}
	}

	public static function checkCutscene(name:String):Bool
		return cutsceneList.contains(name);

	// helper variables
	private var camFollow(get, default):FlxPoint;

	private function get_camFollow():FlxPoint
	{
		return PlayState.current.camFollow;
	}

	public function update(elapsed:Float)
	{
		time += elapsed;

		for (key => functions in lockedUpdateLoops)
		{
			if (functions != null)
				functions();
		}

		while (cutsceneActions[0] != null)
		{
			if (time >= cutsceneActions[0].time)
			{
				if (cutsceneActions[0].action != null)
					cutsceneActions[0].action();

				cutsceneActions.splice(0, 1);
			}
			else
				break;
		}

		if (time >= endTime && !cutsceneFinished)
		{
			if (endCallback != null)
				endCallback();

			lockedUpdateLoops.clear();

			cutsceneFinished = true;
		}
	}

	private function snapCamera(x:Float = 0, y:Float = 0):Void
	{
		camFollow.set(x, y);
		PlayState.current.camFollowObject.setPosition(x, y);
	}
}

typedef CutsceneAction =
{
	var action:Void->Void;
	var time:Float;
}
