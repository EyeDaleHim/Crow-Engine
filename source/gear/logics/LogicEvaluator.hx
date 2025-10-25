package gear.logics;

import gear.assets.metadata.logics.LogicMetadata;

/**
 * A utility class for executing actions defined by `ListenerActionMetadata`.
 */
class LogicEvaluator
{
	/**
	 * Executes a list of actions against the menu's state.
	 * @param actions The array of actions to execute
	 * @param logicState The state map to be read from and modified.
	 * @param entities An optional map of entities to perform actions on (e.g., for animations).
	 */
	public static function execute(actions:Array<ListenerActionMetadata>, logicState:Map<String, Dynamic>, ?entities:Map<String, Entity>):Void
	{
		for (action in actions)
		{
			switch (action.type)
			{
				case "play_animation":
					if (action.sprite != null && action.values != null && action.values.length > 0 && entities != null)
					{
						// Find the entity that contains the target sprite.
						for (entity in entities)
						{
							if (entity != null && entity.spritesMap.exists(action.sprite))
							{
								final sprite = entity.spritesMap.get(action.sprite);
								final animName = action.values[0];
								final force = action.force == true;
								sprite.animation.play(animName, force);
								break; // Assume sprite names are unique across entities for now.
							}
						}
					}

				case "state_change":
					if (action.stateChange != null)
					{
						ActionEvaluator.evaluate(action.stateChange, logicState);
					}
				default:
				// Other actions can be added here.
			}
		}
	}
}