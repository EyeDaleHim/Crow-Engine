package gear;

import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Assets.init();

		Assets.loadContext("persistent");

		Main.game = new FlxGame(0, 0, () -> new gear.states.internals.InitState()); // if confused, use InitState
	}
}