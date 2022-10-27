package;

import flixel.addons.ui.FlxUISubState;
import backend.Controls;
import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class MusicBeatSubState extends FlxUISubState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	public var controls(get, null):Controls;

	function get_controls():Controls
	{
		return cast(FlxG.state, MusicBeatState).controls;
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
	{}

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
		/*for (i in 0...Conductor.bpmChangeMap.length)
			{
				if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
					lastChange = Conductor.bpmChangeMap[i];
		}*/

		curStep = /*lastChange.stepTime +*/ Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
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
}
