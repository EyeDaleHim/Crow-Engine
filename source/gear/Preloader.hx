package gear;

import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Main.assets = new Assets();

		Main.bundle = Bundle.load('assets.bundle');

		Main.assets.loadContext("persistent");

		Main.game = new FlxGame(0, 0, () -> new gear.states.menus.TitleState());
	}
}