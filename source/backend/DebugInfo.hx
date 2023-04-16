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
#if cpp
import cpp.vm.Gc;
#end

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
			var delta:Float = borderSize / iterations;

			for (i in 0...iterations)
			{
				var offset:Float = -delta * i;
				for (dx in [-delta, 0, delta])
				{
					for (dy in [-delta, 0, delta])
					{
						if (dx != 0 || dy != 0)
							addOutline(offset + dx, offset + dy);
					}
				}
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

	private var frameCount:Int = 0;
	private var currentTime:Int = 0;

	private function updateFPS():Void
	{
		var memory = #if cpp Math.floor(Gc.memInfo64(Gc.MEM_INFO_USAGE)) #else System.totalMemory #end;

		for (text in outlines)
			text.visible = false;

		if (memory > memoryPeak)
			memoryPeak = memory;

		if (visible)
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

						if (Settings.getPref("fpsInfo_display", 0) >= 3)
						{
							text += Math.round(ExternalCode.cpuClock()) + "MHZ | ";
							text += Tools.abbreviateNumber(FlxG.stage.context3D.totalGPUMemory, dataSizes) + "\n";
						}
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

						if (Settings.getPref("fpsInfo_display", 0) >= 3)
							{
								text += "CPU: " + Math.round(ExternalCode.cpuClock()) + "MHZ | ";
								text += "GPU: " + Tools.abbreviateNumber(FlxG.stage.context3D.totalGPUMemory, dataSizes) + "\n";
							}
						else
							text += '\n';
					}
			}

			for (text in outlines)
				text.text = this.text;
		}
	}

	private function onEnter(_:Event)
	{
		frameCount = Math.floor((1 / (openfl.Lib.getTimer() - currentTime)) * 1000);

		currentTime = openfl.Lib.getTimer();

		if (FlxG.keys.justPressed.F4)
		{
			if (FlxG.keys.pressed.F3)
				Settings.setPref("fpsInfo_display", Std.int((Settings.getPref("fpsInfo_display") + 1) % 4));
			else
			{
				switch (Settings.getPref("fpsInfo", "default"))
				{
					case 'minimized':
						Settings.setPref("fpsInfo", 'default');
						visible = true;
					case 'default':
						Settings.setPref("fpsInfo", "disable");
						visible = true;
					case 'disable':
						Settings.setPref("fpsInfo", 'minimized');
						visible = false;
				}
			}
		}
	}

	function addOutline(dx:Float, dy:Float):Void
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
	}
}
