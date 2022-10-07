package backend;

import openfl.system.System;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.utils.Assets;

/**
	Class That Displays FPS, Memory, & Memory Peak.
	 
	Based Off Of: https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
 */
class DebugInfo extends TextField
{
	var times:Array<Float> = [];
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

	private function onEnter(_:Event)
	{
		var now = Timer.stamp();
		times.push(now);

		while (times[0] < now - 1)
			times.shift();

		var memory = System.totalMemory;

		if (memory > memoryPeak)
			memoryPeak = memory;

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
			}
		}
	}
}
