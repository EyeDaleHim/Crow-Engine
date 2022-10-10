package backend;

import flixel.FlxG;
import openfl.system.System;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.utils.Assets;

using StringTools;

/**
	Class That Displays FPS, Memory, & Memory Peak.
	 
	Based Off Of: https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
 */
class DebugInfo extends TextField
{
	var times:Array<Null<Float>> = [];
	var memoryPeak:UInt = 0;

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = y;

		autoSize = LEFT;

		selectable = false;

		defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr")).fontName, 12, 0xFFFFFFFF);

		text = "";

		width = 300;
		height = 150;

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	private var _updateMS:Int = 0;
	private var _storedLastMS:Float = 0.0;
	private var lastChangedPeak:Float = 0.0;

	private function onEnter(_:Event)
	{
		var now = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var memory = System.totalMemory;

		if (memory > memoryPeak)
		{
			memoryPeak = memory;
			lastChangedPeak = 0.0;
		}

		if ((lastChangedPeak += FlxG.elapsed) >= 7.5)
		{
			lastChangedPeak = 0.0;

			memoryPeak = Math.floor(memoryPeak - memoryPeak / 10);
			memoryPeak = Math.floor(Math.max(memory, memoryPeak));
		}

		if (visible)
		{
			text = "";

			switch (Settings.getPref("fpsInfo", "default"))
			{
				case 'minimized':
					{
						if (Settings.getPref("showFPS", true))
							text += times.length + '\n';

						if (Settings.getPref("showMemory", true))
							text += Tools.formatMemory(memory);

						if (Settings.getPref("showMemoryPeak", true))
							text += " / " + Tools.formatMemory(memoryPeak) + "\n";
						else
							text += '\n';
					}
				case 'default':
					{
						if (Settings.getPref("showFPS", true))
							text += "FPS: " + times.length + "\n";

						if (Settings.getPref("showMemory", true))
							text += "Memory: " + Tools.formatMemory(memory);

						if (Settings.getPref("showMemoryPeak", true))
							text += " / " + Tools.formatMemory(memoryPeak) + "\n";
						else
							text += '\n';
					}
				#if debug
				case 'debug':
					{
						if (Settings.getPref("showFPS", true))
						{
							text += "FPS: " + times.length;

							if (_updateMS++ >= times.length)
							{
								var lastMS:Float = 0.0;
								var firstPass:Float = 0.0;

								if (times[0] != null)
									firstPass = times[0];

								if (times[1] != null)
									_storedLastMS = lastMS = times[1] - firstPass;

								_updateMS = 0;
							}

							text += ' (${Std.string(_storedLastMS * 1000).substring(0, 5)} ms)\n';
						}

						if (Settings.getPref("showMemory", true))
							text += "Memory: " + Tools.formatMemory(memory);

						if (Settings.getPref("showMemoryPeak", true))
							text += " / " + Tools.formatMemory(memoryPeak);

						text += '\n';
						/**@:privateAccess
							{
								text += '------\nCached Bitmaps: ${FlxG.bitmap._cache.length}';
						}*/
					}
				#end
			}
		}
	}
}
