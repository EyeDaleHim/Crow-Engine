package backend;

import flixel.FlxG;
import openfl.system.System;
import haxe.Timer as HaxeTimer;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.utils.Assets;
import openfl.utils.Timer;

using StringTools;

/**
	Class That Displays FPS, Memory, & Memory Peak.
	 
	Based Off Of: https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
 */
class DebugInfo extends TextField
{
	private var outlines:Array<TextField> = [];

	private var timer:HaxeTimer;
	private var memoryPeak:UInt = 0;

	private static final dataSizes:Array<String> = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

	public function new(x:Float, y:Float, borderSize:Float = 0)
	{
		super();

		this.x = x;
		this.y = y;

		selectable = false;

		defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr")).fontName, 12, 0xFFFFFF);

		text = "";

		if (borderSize > 0)
		{
			var iterations:Int = Std.int(borderSize);
			if (iterations <= 0)
			{
				iterations = 1;
			}
			var delta:Float = borderSize / iterations;
			var curDelta:Float = delta;

			for (i in 0...Std.int(borderSize))
			{
				var copyTextWithOffset:(Float, Float) -> Void = function(dx:Float, dy:Float)
				{
					var textOutline:TextField = new TextField();
					textOutline.x = this.x + dx;
					textOutline.y = this.y + dy;
					textOutline.autoSize = LEFT;

					textOutline.selectable = false;
					textOutline.mouseEnabled = false;
					textOutline.defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr")).fontName, 12, 0x000000);
					textOutline.text = '';

					outlines.push(textOutline);

					Main.instance.addChild(textOutline);
				};

				copyTextWithOffset(-curDelta, -curDelta); // upper-left
				copyTextWithOffset(curDelta, 0); // upper-middle
				copyTextWithOffset(curDelta, 0); // upper-right
				copyTextWithOffset(0, curDelta); // middle-right
				copyTextWithOffset(0, curDelta); // lower-right
				copyTextWithOffset(-curDelta, 0); // lower-middle
				copyTextWithOffset(-curDelta, 0); // lower-left
				copyTextWithOffset(0, -curDelta); // lower-left

				curDelta += delta;
			}
		}

		width = 300;
		height = 150;

		autoSize = LEFT;
		backgroundColor = 0;

		timer = new HaxeTimer(1000);
		timer.run = updateFPS;

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	private var _updateMS:Int = 0;
	private var _storedLastMS:Float = 0.0;
	private var lastChangedPeak:Float = 0.0;
	private var frameCount:Int = 0;

	private function updateFPS():Void
	{
		var memory = System.totalMemory;

		for (text in outlines)
			text.visible = false;

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

		if (visible = !(Settings.getPref("fpsInfo", "default") == 'disable'))
		{
			for (text in outlines)
				text.visible = true;

			text = "";

			switch (Settings.getPref("fpsInfo", "default"))
			{
				case 'minimized':
					{
						if (Settings.getPref("fpsInfo_display", 0) >= 0)
							text += Math.min(frameCount, Settings.getPref('framerate', 60)) + '\n';

						if (Settings.getPref("fpsInfo_display", 0) >= 1)
							text += Tools.abbreviateNumber(memory, dataSizes);

						if (Settings.getPref("fpsInfo_display", 0) >= 2)
							text += " / " + Tools.abbreviateNumber(memoryPeak, dataSizes) + "\n";
						else
							text += '\n';
					}
				case 'default':
					{
						if (Settings.getPref("fpsInfo_display", 0) >= 0)
							text += "FPS: " + Math.min(frameCount, Settings.getPref('framerate', 60)) + "\n";

						if (Settings.getPref("fpsInfo_display", 0) >= 1)
							text += "Memory: " + Tools.abbreviateNumber(memory, dataSizes);

						if (Settings.getPref("fpsInfo_display", 0) >= 2)
							text += " / " + Tools.abbreviateNumber(memoryPeak, dataSizes) + "\n";
						else
							text += '\n';
					}
			}

			for (text in outlines)
				text.text = this.text;
		}

		frameCount = 0;
	}

	private function onEnter(_:Event)
	{
		frameCount++;

		if (FlxG.keys.justPressed.F3)
		{
			if (FlxG.keys.pressed.F4)
				Settings.setPref("fpsInfo_display", Std.int((Settings.getPref("fpsInfo_display") + 1) % 3));
			else
			{
				switch (Settings.getPref("fpsInfo", "default"))
				{
					case 'minimized':
						Settings.setPref("fpsInfo", 'default');
					case 'default':
						Settings.setPref("fpsInfo", "disable");
					case 'disable':
						Settings.setPref("fpsInfo", 'minimized');
				}
			}
		}
	}
}
