package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class MusicBeatState extends FlxUIState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	override function create()
	{
		if (transIn != null)
			trace('reg ' + transIn.region);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// everyStep();
		var oldStep:Int = curStep;

		if (FlxG.keys.justPressed.F2 && FlxG.keys.pressed.CONTROL)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		super.update(elapsed);
	}

    public function load():Void // doesn't do anything really, you just have to override it
    {
        
    }

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		// do literally nothing dumbass
	}

    override public function onFocusLost():Void
    {
        super.onFocusLost();
        
        if (FlxG.autoPause)
            return;

        if (FlxG.sound.music != null)
        {
            FlxTween.tween(FlxG.sound.music, {volume: 0.2}, 1.5);
        }
    }

    override public function onFocus():Void
    {
        super.onFocus();
        
        if (FlxG.autoPause)
            return;

        if (FlxG.sound.music != null)
        {
            FlxTween.tween(FlxG.sound.music, {volume: 1}, 1.5);
        }
    }
}
