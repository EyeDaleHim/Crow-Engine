package gear.logics;

import gear.assets.metadata.logics.ActionMetadata;

/**
 * A utility class for evaluating state-changing actions defined by `ActionMetadata`.
 */
class ActionEvaluator
{
	/**
	 * Evaluates a state change action and modifies the provided state map.
	 * @param action The metadata defining the state change.
	 * @param state The state map to modify.
	 */
	public static function evaluate(action:ActionMetadata, state:Map<String, Dynamic>):Void
	{
		switch (action.changeType)
		{
			case SET:
				state.set(action.stateKey, action.value);
			case INCREMENT:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Float))
					state.set(action.stateKey, state.get(action.stateKey) + action.value);
			case TOGGLE:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Bool))
					state.set(action.stateKey, !state.get(action.stateKey));
			default:
		}
	}
}