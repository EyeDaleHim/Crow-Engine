package gear;

import openfl.Lib;
import flixel.input.keyboard.FlxKey;
import openfl.display.DisplayObjectContainer;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var bundle:Bundle;

	public function new()
	{
		super();

		#if TRACY_ENABLED
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) ->
		{
			cpp.vm.tracy.TracyProfiler.frameMark();
		});
		#end

		Lib.current.addChild(game);
	}
}
