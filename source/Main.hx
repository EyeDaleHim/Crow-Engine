package;

import system.gameplay.ChartConverter;

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

		gameInstance = new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		addChild(gameInstance);

		Discord.init();
		Logs.init();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e)
		{
			if (FlxG.keys.checkStatus(e.keyCode, JUST_PRESSED))
			{
				if (e.keyCode == FlxKey.F3)
				{
					if (ScreenEditorState.isActive)
					{
						var state:ScreenEditorState = cast(FlxG.state, ScreenEditorState);
						if (state.editorActive)
							state.closeEditors();
						else
							state.bringUpEditors();
					}
					else
						FlxG.switchState(new ScreenEditorState());
				}
			}
		});

		FlxG.stage.application.window.onDropFile.add(readFolderAndConvertChart);

		if (FileSystem.exists(Assets.assetPath('data/weeks/meta.json')))
		{
			var meta:WeekGlobalMetadata = cast Json.parse(Assets.readText(Assets.assetPath('data/weeks/meta.json')));

			if (meta.list?.length != 0)
			{
				for (week in meta.list)
					DataManager.importWeekFile(week);
			}
			else
				FlxG.log.error('Couldn\'t find your Week Global Metadata, please check ${Assets.assetPath('data/weeks/meta.json')}');
		}
	}

	public static function readFolderAndConvertChart(rawPath:String)
	{
		function convertChart(filePath:String)
		{
			var path:Path = new Path(filePath);
			var data:Dynamic = Json.parse(File.getContent(path.toString()));
			var convertedData:ChartData = ChartConverter.convertPsychToCrow(data);
			FileSystem.createDirectory('converted_charts');
			File.saveContent('converted_charts/${path.file}.${path.ext}', Json.stringify(convertedData));
		}

		if (FileSystem.isDirectory(rawPath))
		{
			for (file in FileSystem.readDirectory(rawPath))
			{
				if (FileSystem.isDirectory(Path.join([rawPath, file])))
					readFolderAndConvertChart(Path.join([rawPath, file]));
			}
		}
		else
		{
			try
			{
				convertChart(rawPath);
			}
		}
	}
}
