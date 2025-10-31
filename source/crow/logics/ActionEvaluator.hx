package crow.logics;

import crow.assets.metadata.logics.ActionMetadata;

/**
 * A utility class for evaluating state-changing actions defined by `ActionMetadata`.
 */
class ActionEvaluator
{
	/**
	 * Evaluates a state change action and modifies the provided state map.
	 * @param action The metadata defining the state change.
	 * @param globalState The primary state map to modify.
	 * @param ?localState A secondary, temporary state map.
	 */
	public static function evaluate(action:ActionMetadata, globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):Void
	{
		final scope = action.scope ?? "global";
		final state:LogicState = switch (scope)
		{
			case "local": localState;
			case "entity": entityState;
			default: globalState;
		};

		if (state == null)
		{
			trace('Warning: Cannot perform state_change. LogicState for scope "${scope}" is null.');
			return;
		}

		switch (action.changeType)
		{
			case SET:
				state.set(action.stateKey, action.value);
			case INCREMENT | DECREMENT:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Float))
				{
					final value:Float = (action.changeType == INCREMENT) ? action.value : -action.value;
					state.set(action.stateKey, state.get(action.stateKey) + value);
				}
			case TOGGLE:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Bool))
					state.set(action.stateKey, !state.get(action.stateKey));
			default:
		}
	}
}