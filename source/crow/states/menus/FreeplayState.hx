package crow.states.menus;

import crow.states.internals.BaseMenuState;
import crow.assets.metadata.logics.LogicMetadata;
import crow.assets.metadata.scenes.MenuMetadata;
import crow.logics.dependencies.LogicState;

class FreeplayState extends BaseMenuState
{
	public var noSongsText:Entity;

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

		noSongsText = new Entity("freeplay/no_songs");
		noSongsText.screenCenter(Y);
		add(noSongsText);
		entities.set(noSongsText.entityName, noSongsText);
	}

	override public function handleMenuAction(action:ListenerActionMetadata, ?menuItem:MenuItem, ?entity:Entity, ?localState:LogicState):Void
	{
		if (action.type == "toggle_nosongs")
		{
			noSongsText.exists = localState.get("show") ?? false;
			return;
		}
		super.handleMenuAction(action, menuItem, entity, localState);
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
