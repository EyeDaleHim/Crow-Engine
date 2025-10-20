package gear;

import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Main.assets = new Assets();

		#if ASSETS_PACKAGING
		Main.bundle = Bundle.load('assets.bundle');
		#end

		Main.assets.loadContext("persistent");

		Main.game = new FlxGame(0, 0, () -> new gear.states.menus.TitleState());
	}
}