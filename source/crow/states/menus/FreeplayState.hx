package crow.states.menus;

import crow.assets.metadata.logics.LogicMetadata;
import crow.ds.orderedmap.OrderedStringMap;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.states.internals.BaseMenuState;

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

		noSongsText = new Entity("freeplay/no_songs");
		noSongsText.getModel().screenCenter(Y);

		buildMenu();

		add(noSongsText);
		entities.set(noSongsText.entityName, noSongsText);
	}

	override public function executeLogic(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState,
			?entities:OrderedStringMap<Entity>, ?executor:IEventExecutor):Void
	{
		for (action in actions)
		{
			if (action.values?.name ==  "check_empty")
			{
				actions.remove(action);
				noSongsText.visible = action.values.actions?.show ?? false;
			}
		}
		super.executeLogic(actions, executorState, localState, entities, executor);
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
