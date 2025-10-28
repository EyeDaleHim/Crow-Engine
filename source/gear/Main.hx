package gear;

import openfl.Lib;
import openfl.display.DisplayObjectContainer;

class Main extends DisplayObjectContainer
{
	public static var game:FlxGame;
	public static var bundle:Bundle;

	public static var assets:Assets;
	public static var input:Input;

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

		// testing my bullshit
		var msgPack = gear.assets.format.MessagePack.serialize({
			test: 1,
			test2: "hello",
			test3: [1, 2, 3],
			test4:
			{
				test5: 1
			}
		});
		trace(gear.assets.format.MessagePack.parse(msgPack));

		Lib.current.addChild(game);
	}
}
