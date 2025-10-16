package;

import openfl.Lib;
import flixel.FlxGame;
import flixel.input.keyboard.FlxKey;
import openfl.display.DisplayObjectContainer;
import openfl.events.KeyboardEvent;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;

	public function new()
	{
		super();

		#if TRACY_ENABLED
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) ->
		{
			cpp.vm.tracy.TracyProfiler.frameMark();
		});
		#end

		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) ->
		{
			backend.engine.external.AudioContextManager.checkDeviceChange();
		});

		backend.engine.external.DPIAwareness.registerAsDPICompatible();

		FlxGraphic.defaultPersist = true;

		Lib.current.addChild(game);
	}
}
