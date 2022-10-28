package states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class PauseSubState extends MusicBeatSubState
{
	public var background:FlxSprite;

	override function create()
	{
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		background.active = false;
		background.alpha = 0.0;
		add(background);

		FlxTween.tween(background, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [PlayState.current.pauseCamera];

		super.create();
	}

	private var firstFrame:Bool = false; // whoops

	override function update(elapsed:Float)
	{
		if (!firstFrame)
		{
			firstFrame = true;
			super.update(elapsed);
			return;
		}

		@:privateAccess
		{
			if (controls.getKey('UI_UP', JUST_PRESSED))
				PlayState.current.controlScale += 0.01;
			if (controls.getKey('UI_DOWN', JUST_PRESSED))
				PlayState.current.controlScale -= 0.01;
			PlayState.current.manageNotes();
		}

		if (controls.getKey('PAUSE', JUST_PRESSED))
			close();

		// leave debug key editors in here, not playstate

		super.update(elapsed);
	}
}
