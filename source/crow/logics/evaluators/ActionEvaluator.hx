package crow.logics.evaluators;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.dependencies.LogicState;
import crow.logics.tools.ValidatorLevel;
import crow.logics.validators.ActionValidator;

/**
 * A utility class for evaluating state-changing actions defined by `ActionMetadata`.
 */
class ActionEvaluator
{
	/**
	 * Requires actions to be valid and type-safe before it is processed on-demand.
	 * 
	 * Disabling this will incur some performance benefit.
	 */
	public static var validationLevel:ValidatorLevel = REQUIRED;

	/**
	 * Evaluates a state change action and modifies the provided state map.
	 * @param action The metadata defining the state change.
	 * @param globalState The primary state map to modify.
	 * @param localState A secondary, temporary state map.
	 * @param entityState A third state map, typically associated with a specific entity.
	 */
	public static function evaluate(action:ActionMetadata, globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):Void
	{
		switch (validationLevel)
		{
			case REQUIRED:
				if (!ActionValidator.validate(action))
					return;
			case WARN:
				ActionValidator.validate(action);
			case NONE:
			
		}

		final scope = action.scope ?? GLOBAL;
		final state:LogicState = switch (scope)
		{
			case LOCAL: localState;
			case ENTITY: entityState;
			default: globalState;
		};

		switch (action.changeType)
		{
			case SET:
				state.set(action.stateKey, action.value);
			case INCREMENT | DECREMENT:
				// For integer increments/decrements
				untyped final change:Int = (action.changeType == INCREMENT) ? action.value : -action.value;
				state.set(action.stateKey, state.get(action.stateKey) + change);
			case ADD | SUBTRACT:
				// For float addition/subtraction
				final value:Float = (action.changeType == ADD) ? action.value : -action.value;
				state.set(action.stateKey, state.get(action.stateKey) + value);
			case MULTIPLY:
				state.set(action.stateKey, state.get(action.stateKey) * action.value);
			case DIVIDE:
				state.set(action.stateKey, state.get(action.stateKey) / action.value);
			case TOGGLE:
				state.set(action.stateKey, !state.get(action.stateKey));
			default:
		}
	}
}