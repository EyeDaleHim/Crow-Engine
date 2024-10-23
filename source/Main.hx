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

		FlxG.save.bind("CrowEngine/save", "EyeDaleHim");

		gameInstance = new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen);
		addChild(gameInstance);

		Controls.init();
		Discord.init();
		Logs.init();

		FlxG.autoPause = false;

		Controls.registerRawKey([F3], JUST_PRESSED, function()
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
				FlxG.switchState(() -> new ScreenEditorState());
		}, {persist: true});

		FlxG.stage.application.window.onDropFile.add(function(str)
		{
			readFolderAndConvertChart(str);
		});

		if (FileSystem.exists(Assets.assetPath('data/weeks/meta.json')))
		{
			var meta:WeekGlobalMetadata = cast Json.parse(Assets.readText(Assets.assetPath('data/weeks/meta.json')));

			if (meta.list?.length != 0)
			{
				for (week in meta.list)
					WeekManager.importWeekFile(week);
			}
			else
				Logs.error('Couldn\'t find your Week Global Metadata, please check ${Assets.assetPath('data/weeks/meta.json')}');
		}
	}

	public static function readFolderAndConvertChart(rawPath:String, ?outputPath:String)
	{
		FileSystem.createDirectory('converted_charts');

		function convertChart(filePath:String)
		{
			var path:Path = new Path(filePath);
			var data:Dynamic = null;

			try
			{
				data = Json.parse(File.getContent(path.toString()));
			} catch (e)
			{
				trace(e.message);
				data = null;
			}

			var convertedData:ChartData = ChartConverter.classifyAndConvert(data);

			if (convertedData.crowIdentifer != null)
			{
				var filename:String = path.file;
				if (!path.file.endsWith('-hard') && !path.file.endsWith('-easy'))
					filename = '${path.file}-normal';

				if (outputPath != null)
					File.saveContent('$outputPath/$filename.${path.ext}', Json.stringify(convertedData));
				else
					File.saveContent('converted_charts/$filename', Json.stringify(convertedData));
			}
		}

		if (FileSystem.isDirectory(rawPath))
		{
			var outputPath:String = 'converted_charts/${Path.withoutDirectory(rawPath)}';
			FileSystem.createDirectory(outputPath);
			for (folder in FileSystem.readDirectory(rawPath))
			{
				readFolderAndConvertChart(Path.join([rawPath, folder]), outputPath);
			}
		}
		else if (rawPath.endsWith('.json'))
		{
			convertChart(rawPath);
		}
	}
}
