package crow;

import crow.game.levels.LevelRegistry;
import openfl.Lib;
import openfl.display.DisplayObjectContainer;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var bundle:Bundle;

	public static var assets:Assets;
	public static var input:Input;

	public static var levels:LevelRegistry;

	public function new()
	{
		super();

		#if TRACY_ENABLED
		openfl.Lib.current.stage.addEventListener(openfl.events.Event.EXIT_FRAME, (e:openfl.events.Event) ->
		{
			cpp.vm.tracy.TracyProfiler.frameMark();
		});
		#end

		Main.input = new Input(Input.inputPath);
		FlxG.signals.preUpdate.add(() ->
		{
			Main.input.update(FlxG.elapsed);
		});
		FlxG.signals.postUpdate.add(() ->
		{
			Main.input.postUpdate();
		});

		Lib.current.addChild(game);
	}
}
