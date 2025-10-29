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

		openCallback = onReturn;
	}

	public function onReturn():Void
	{
		onEvent("skipIntro");
	}
}
