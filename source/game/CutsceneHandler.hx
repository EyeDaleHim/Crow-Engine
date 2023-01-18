package game;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import states.PlayState;

class CutsceneHandler
{
	public static final cutsceneList:Array<String> = ['winter-horrorland', 'eggnog', 'ugh', 'guns', 'stress'];

	public var time:Float = 0.0;
	public var endTime:Float = 0.0;
	public var cutscene:String;

	public var endCallback:Void->Void = null;
	public var cutsceneIsFinished:Bool = false;

	public var cutsceneActions:Array<CutsceneAction> = [];
	public var lockedUpdateLoops:Map<String, Void->Void> = [];

	public function new(cutscene:String)
	{
		this.cutscene = cutscene.split('-##')[0];

		if (cutscene.split('-##').length == 1)
			cutscene += '-##start';

		trace('starting ${cutscene}');

		switch (cutscene.split('-##')[0])
		{
			case 'eggnog':
				{
					if (cutscene.split('-##')[1] == 'end') {}
				}
			case 'winter-horrorland':
				{
					if (cutscene.split('-##')[1] == 'start')
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
					if (cutscene.split('-##')[1] == 'start')
					{
						@:privateAccess
						{
							lockedUpdateLoops.set('lockCharUpdate', function()
							{
								PlayState.current.player._animationTimer = 0.0;
								PlayState.current.spectator._animationTimer = 0.0;
								PlayState.current.opponent._animationTimer = 0.0;
							});

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
									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x + 600, y: calculatedPosition.y + 90}, 0.9, {
										ease: FlxEase.quadOut,
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
										player.playAnim('idle', true, true);
										player.animation.curAnim.pause();
									});
								},
								time: 4.5
							});

							cutsceneActions.push({
								action: function()
								{
									FlxTween.tween(calculatedPosition, {x: calculatedPosition.x - 600, y: calculatedPosition.y - 90}, 0.9, {
										ease: FlxEase.quadOut,
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
									FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.attributes['zoomLerpValue']}, 1.0, {ease: FlxEase.quadOut});
									FlxTween.tween(PlayState.current.hudCamera, {alpha: 1.0}, 1.5, {ease: FlxEase.quadInOut});

									opponent.frames = Paths.getSparrowAtlas('characters/${opponent.name}/${opponent.name}');
									opponent.animation.play('idle', true);
								},
								time: 11.9
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

		if (time >= endTime && !cutsceneIsFinished)
		{
			if (endCallback != null)
				endCallback();

			lockedUpdateLoops.clear();

			cutsceneIsFinished = true;
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
