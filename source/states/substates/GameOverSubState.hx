package states.substates;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import objects.character.Character;
import states.PlayState;

class GameOverSubState extends MusicBeatSubState
{
	public var camFollow:FlxObject;
	public var player:Character;

	override function create()
	{
		add(player = PlayState.current.player);

		player.playAnim('firstDeath', true);

		camFollow = cast PlayState.current.camFollowObject;
		FlxG.camera.follow(camFollow, null, 1.0);

		FlxG.sound.music.stop();
		if (PlayState.current.vocals != null && PlayState.current.vocals.playing)
			PlayState.current.vocals.stop();

		FlxG.sound.play(Paths.sound('game/death/fnf_loss_sfx'), 0.80);
		(music = new FlxSound()).loadEmbedded(Paths.music('gameOver'), true);
		FlxG.sound.list.add(music);

		Conductor.changeBPM();

		super.create();
	}

	public var triggeredFollow:Bool = false;

	override function update(elapsed:Float)
	{
		if (player.animation.curAnim.name != 'confirmDeath')
		{
			if (music != null && music.playing)
				Conductor.songPosition = music.time;
		}

		if (player.animation.curAnim != null && player.animation.curAnim.name == 'firstDeath')
		{
			if (player.animation.curAnim.curFrame >= 12 && !triggeredFollow)
			{
				triggeredFollow = true;

				FlxTween.tween(camFollow, {x: player.getGraphicMidpoint().x, y: player.getGraphicMidpoint().y}, 2, {ease: FlxEase.quadOut});
			}

			if (player.animation.curAnim.finished && !hasPlayed)
				startGameOver();
		}

		if (controls.getKey('ACCEPT', JUST_PRESSED))
		{
			player.playAnim('confirmDeath', true);

			music.stop();
			music.loadEmbedded(Paths.music('gameOverEnd'), true);
			music.play(true);

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxTween.tween(FlxG.camera, {alpha: 0.0}, 2, {
					onComplete: function(twn:FlxTween)
					{
						MusicBeatState.switchState(new states.PlayState());
					}
				});
			});
		}
		else if (controls.getKey('BACK', JUST_PRESSED))
		{
			if (PlayState.playMode == STORY)
				MusicBeatState.switchState(new states.menus.StoryMenuState());
			else
				MusicBeatState.switchState(new states.menus.FreeplayState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			Conductor.changeBPM(102);
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		player.playAnim('deathLoop', true);
	}

	public var music:FlxSound;
	public var hasPlayed:Bool = false;

	public function startGameOver():Void
	{
		hasPlayed = true;
		music.play(true);
	}
}
