package;

class Main extends Sprite
{
	static final game = {
		width: 1280, // Game Width
		height: 720, // Game Height
		initialState: states.menus.MainMenuState, // The State when the game starts
		framerate: 60, // Default Framerate of the Game
		skipSplash: true, // Skipping Flixel's Splash Screen
		startFullscreen: false // If the game should start fullscreen
	};

	public static var instance:Main;
	public static var gameInstance:FlxGame;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		instance = this;

		game.framerate = Math.min(game.framerate, 480).floor();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		gameInstance = new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen);
		addChild(gameInstance);
	}
}