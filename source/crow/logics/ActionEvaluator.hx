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
	 * @param localState A secondary, temporary state map.
	 * @param entityState A third state map, typically associated with a specific entity.
	 */
	public static function evaluate(action:ActionMetadata, globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):Void
	{
		final scope = action.scope ?? GLOBAL;
		final state:LogicState = switch (scope)
		{
			case LOCAL: localState;
			case ENTITY: entityState;
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
				// For integer increments/decrements
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Int))
				{
					final change:Int = (action.changeType == INCREMENT) ? Std.int(action.value) : Std.int(-action.value);
					state.set(action.stateKey, state.get(action.stateKey) + change);
				}
			case ADD | SUBTRACT:
				// For float addition/subtraction
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Float))
				{
					final value:Float = (action.changeType == ADD) ? action.value : -action.value;
					state.set(action.stateKey, state.get(action.stateKey) + value);
				}
			case MULTIPLY:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Float))
				{
					state.set(action.stateKey, state.get(action.stateKey) * action.value);
				}
			case DIVIDE:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Float))
				{
					if (action.value != 0)
					{
						state.set(action.stateKey, state.get(action.stateKey) / action.value);
					}
					else
					{
						trace('Warning: Division by zero attempted for state key "${action.stateKey}". Operation skipped.');
					}
				}
			case TOGGLE:
				if (state.exists(action.stateKey) && Std.isOfType(state.get(action.stateKey), Bool))
				{
					state.set(action.stateKey, !state.get(action.stateKey));
				}
			default:
		}
	}
}