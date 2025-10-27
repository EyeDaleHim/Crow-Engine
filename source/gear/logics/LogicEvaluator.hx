package gear.logics;

import gear.states.internals.BaseMenuState;
import gear.assets.metadata.logics.ActionMetadata;
import gear.assets.metadata.logics.LogicMetadata;
import gear.entities.AnimatedText;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	public static function execute(actions:Array<ListenerActionMetadata>, logicState:Map<String, Dynamic>, ?entities:Map<String, Entity>,
			?menuState:BaseMenuState):Void
	{
		for (action in actions)
		{
			// Get the list of targeted entities using the new filter system.
			final targetedEntities = (entities != null && action.targets != null) ? EntityFilter.filterEntities(entities, action.targets) : [];

			switch (action.type)
			{
				case "play_animation":
					if (action.values != null && action.values.length > 0)
					{
						for (entity in targetedEntities)
						{
							// TODO: Filters for sprites within entities?
							entity.forEachOfType(FlxSprite, (spr) ->
							{
								final animName:String = action.values[0];
								final force:Bool = (action.values.length > 1 && action.values[1] == true);
								spr.animation.play(animName, force);
							});
						}
					}

				case "state_change":
					final stateChange:ActionMetadata = action.values[0];
					ActionEvaluator.evaluate(stateChange, logicState);

				case "set_text" | "add_text" | "clear_text":
					for (entity in targetedEntities)
					{
						entity.forEachOfType(AnimatedText, (textObject) ->
						{
							switch (action.type)
							{
								case "set_text":
									textObject.text = action.values.join("\n");
								case "add_text":
									textObject.text += (textObject.text == "" ? "" : "\n") + action.values.join("\n");
								case "clear_text":
									textObject.text = "";
								default:
							}
						});
					}
					
				case "set_visibility":
					if (action.values != null && action.values.length > 0)
					{
						for (entity in targetedEntities)
						{
							entity.visible = action.values[0];
						}
					}

				case "dispatch_event":
					if (action.values != null && action.values.length > 0 && menuState != null)
					{
						final eventName:String = action.values[0];
						final eventArgs:Map<String, Dynamic> = (action.values.length > 1) ? action.values[1] : null;
						menuState.onEvent(eventName, eventArgs);
					}

				case "destroy_entity":
					for (entity in targetedEntities)
					{
						if (entities.exists(entity.entityName))
						{
							entity.destroy();
							entities.remove(entity.entityName); // Remove from map after destroying
						}
					}

				default:
					// Other actions can be added here.
			}
		}
	}
}
