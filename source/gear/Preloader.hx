package;

import flixel.system.FlxBasePreloader;
import flixel.util.FlxStringUtil;
import openfl.system.System;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Main.game = new FlxGame(0, 0, () -> new gear.states.internals.InitState()); // if confused, use InitState
	}
}