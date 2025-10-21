package gear;

import openfl.Lib;
import openfl.display.DisplayObjectContainer;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var bundle:Bundle;

	public static var assets:Assets;

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
