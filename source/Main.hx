package;

import openfl.Lib;
import flixel.FlxGame;
import flixel.graphics.FlxGraphic;
import flixel.input.keyboard.FlxKey;
import openfl.display.DisplayObjectContainer;

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

		FlxGraphic.defaultPersist = true;

		game = new FlxGame(true, false);

		Lib.current.addChild(game);
	}
}
