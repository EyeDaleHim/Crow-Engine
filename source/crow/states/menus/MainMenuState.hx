package crow.states.menus;

import crow.states.internals.BaseMenuState;
import crow.states.internals.BaseMenuState;

class MainMenuState extends BaseMenuState
{
	public function new()
	{
		super();

		nextScenes = ["story_mode", "freeplay", "settings"];

		try
		{
			menuMetadata = cast Main.assets.json('data/menus/main_menu');
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
			// case "story_mode": new StoryModeMenuState();
			// case "freeplay": new FreeplayMenuState();
			// case "settings": new SettingsMenuState();
			default:
				null;
		}
	}
}
