package crow.states.menus;

import crow.states.internals.BaseMenuState;

class FreeplayState extends BaseMenuState
{
	public function new()
	{
		super();

		nextScenes = ["gameplay"];

		try
		{
			menuMetadata = cast Main.assets.json('data/menus/freeplay');
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		buildMenu();
	}

	override public function createScene(sceneName:String):BaseMenuState
	{
		return switch (sceneName)
		{
			default:
				null;
		}
	}
}
