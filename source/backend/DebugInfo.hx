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
import openfl.display.Shader;
import openfl.filters.ShaderFilter;

using StringTools;

/**
	Class That Displays FPS, Memory, & Memory Peak.
	 
	Based Off Of: https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
 */
class DebugInfo extends TextField
{
	private var timer:HaxeTimer;
	private var memoryPeak:UInt = 0;
	private var textShader = new Shader();

	public function new(x:Float, y:Float)
	{
		super();

		this.x = x;
		this.y = y;

		textShader.glFragmentSource = "
		#pragma header

		void main() {
			float x = 1.0 / openfl_TextureSize.x;
			float y = 1.0 / openfl_TextureSize.y;

			vec4 col = texture2D(bitmap, openfl_TextureCoordv.st);
			vec4 smp = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x * -1.0, y * -1.0));

			if (smp.a > 0.0) {
				gl_FragColor = mix(vec4(0.3, 0.3, 0.3, 1.0), col, col.a);
			}
			else {
				gl_FragColor = col;
			}
		";

		filters = [new ShaderFilter(textShader)];

		autoSize = LEFT;

		selectable = false;

		defaultTextFormat = new TextFormat(Assets.getFont(Paths.font("vcr")).fontName, 12, 0xFFFFFFFF);
		alpha = 0.2;

		text = "";

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
			text = "";

			switch (Settings.getPref("fpsInfo", "default"))
			{
				case 'minimized':
					{
						if (Settings.getPref("fpsInfo_display", 0) >= 0)
							text += Math.min(frameCount, Settings.getPref('framerate', 60)) + '\n';

						if (Settings.getPref("fpsInfo_display", 0) >= 1)
							text += Tools.formatMemory(memory);

						if (Settings.getPref("fpsInfo_display", 0) >= 2)
							text += " / " + Tools.formatMemory(memoryPeak) + "\n";
						else
							text += '\n';
					}
				case 'default':
					{
						if (Settings.getPref("fpsInfo_display", 0) >= 0)
							text += "FPS: " + frameCount + "\n";

						if (Settings.getPref("fpsInfo_display", 0) >= 1)
							text += "Memory: " + Tools.formatMemory(memory);

						if (Settings.getPref("fpsInfo_display", 0) >= 2)
							text += " / " + Tools.formatMemory(memoryPeak) + "\n";
						else
							text += '\n';
					}
			}
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
