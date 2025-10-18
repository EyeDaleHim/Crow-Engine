package gear;

import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Assets.init();

		Main.bundle = Bundle.load('assets.bundle');

		Assets.loadContext("persistent");

		Main.game = new FlxGame(0, 0, () -> new gear.states.internals.InitState());
	}
}