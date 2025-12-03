package crow;

import flixel.system.FlxBasePreloader;

class Preloader extends FlxBasePreloader
{
	public function new()
	{
		super();

		FlxGraphic.defaultPersist = true;

		Main.version = SemVer.fromString(FlxG.stage.application.meta.get("version")) ?? new SemVer(0, 0, 0);

		Main.assets = new Assets();

		#if ASSETS_PACKAGING
		Main.bundle = Bundle.load('assets.bundle');
		#end

		Main.levels = new crow.game.levels.LevelRegistry();

		crow.ecs.managers.ComponentTable.init();
		crow.logics.evaluators.LogicEvaluator.init();

		Main.game = new FlxGame(0, 0, () -> new crow.states.internals.RootState(() -> new crow.states.menus.TitleState()));
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;
		FlxG.sound.muteKeys = null;
		FlxG.sound.soundTrayEnabled = false;

		
	}
}
