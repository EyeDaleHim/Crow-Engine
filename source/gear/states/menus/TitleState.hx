package gear.states.menus;

import gear.states.internals.BaseMenuState;

class TitleState extends BaseMenuState
{
	private var randomPair:Array<String>;

	public function new()
	{
		super();

		Main.assets.loadContext("persistent");
		Main.assets.loadContext("title");

		menuMusic = new Music("music/menu/main");
		menuMusic.onBeat.add(onBeat);
		add(menuMusic);

		try
		{
			menuMetadata = cast Main.assets.json('data/menus/title');
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		if (Reflect.hasField(menuMetadata, "randomTextPairs"))
		{
			final randomTextPairs:Array<Array<String>> = Reflect.field(menuMetadata, "randomTextPairs");
			if (randomTextPairs != null && randomTextPairs.length > 0)
				logicState.set("randomText", FlxG.random.getObject(randomTextPairs));
		}

		buildMenu();

		FlxTimer.wait(1, () ->
		{
			menuMusic.play();
			menuMusic.soundObject.fadeIn(4, 0, 0.7);
		});

		menuMusic.onBeat.add(onBeat);
		openCallback = onReturn;
	}

	public function onReturn():Void
	{
		menuMusic.onBeat.add(onBeat);
		FlxTimer.wait(1, () -> onEvent("skipIntro"));
	}
}
