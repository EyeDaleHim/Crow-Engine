package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import backend.data.Controls;
import backend.Transitions;
import sys.FileSystem;

#if SCRIPTS_ALLOWED
import backend.ScriptHandler;
import mods.states.ScriptedState;
import tea.TeaScript;
#end

@:access(MusicBeatState.callAssetsToCache)
class MusicBeatState extends FlxUIState
{
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var curSection:Int = 0;

	public var controls(default, null):Controls = new Controls();

	private static var callFunctions:Array<Void->Void> = [];

	override function create()
	{
		if (_finishedFade)
		{
			_finishedFade = false;
			Transitions.transition(0.5, Out, FlxEase.linear, Slider_Down, {
				startCallback: function()
				{
					for (func in callFunctions)
					{
						func();
					}

					callFunctions = [];
				},
				updateCallback: null,
				endCallback: null
			});
		}

		super.create();

		#if SCRIPTS_ALLOWED
		for (key => script in TeaScript.global)
			script.call("create", []);
		#end

		#if cpp
		cpp.vm.Gc.run(true);
		#end
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
		updateSection();

		if (oldStep != curStep && curStep >= 0)
			stepHit();

		#if SCRIPTS_ALLOWED
		for (key => script in TeaScript.global)
			script.call("update", [elapsed]);
		#end

		super.update(elapsed);
	}

	public function load():Void // doesn't do anything really, you just have to override it
	{
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateSection():Void
	{
		curSection = Math.floor(curBeat / 4);
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

	private static var _finishedFade:Bool = false;

	public static function switchState(state:FlxState, onFinishTransition:Void->Void = null)
	{
		#if SCRIPTS_ALLOWED
		var stateName:String = Std.string(state);

		if (stateName != 'MusicBeatState')
		{
			var path:String = Paths.getPathAsFolder('scripts/states/$stateName');

			if (FileSystem.exists(path))
			{
				var overrideState:Bool = false;
				var dir:Array<String> = FileSystem.readDirectory(path);
				for (file in dir)
				{
					if (file.contains('override'))
					{
						overrideState = true;
						break;
					}
				}
				if (overrideState)
					state = new ScriptedState(stateName);
			}
		}
		#end

		Transitions.transition(0.5, In, FlxEase.linear, Slider_Down, {
			// in case you wanna do something, these two aren't useful for now
			startCallback: null,
			updateCallback: null,
			endCallback: function()
			{
				_finishedFade = true;

				if (onFinishTransition != null)
					callFunctions.push(onFinishTransition);

				for (asset in cast(state, MusicBeatState).callAssetsToCache())
				{
					backend.graphic.CacheManager.setBitmap(asset);
				}
				FlxG.switchState(state);
			}
		});
	}

	// empty function that can be used to return a list of asset paths that can be cached automatically by the asset manager
	private function callAssetsToCache():Array<String>
	{
		return [];
	}

	public function stepHit():Void
	{
		#if SCRIPTS_ALLOWED
		for (key => script in TeaScript.global)
			script.call("stepHit", [curStep]);
		#end

		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		#if SCRIPTS_ALLOWED
		for (key => script in TeaScript.global)
			script.call("beatHit", [curBeat]);
		#end

		if (curBeat % 4 == 0)
			sectionHit();
	}

	public function sectionHit():Void
	{
	}

	override public function toString():String
	{
		return "MusicBeatState";
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
