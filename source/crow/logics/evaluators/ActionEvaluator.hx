package crow.logics.evaluators;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.dependencies.LogicState;
import crow.logics.tools.ActionScope;
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
	 * Evaluates a state change action and modifies the state located within the provided scopes.
	 * @param action The metadata defining the state change.
	 * @param scopes A map of available LogicStates keyed by their scope name.
	 */
	public static function evaluate(action:ActionMetadata, scopes:Map<String, LogicState>):Void
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

		final scope = action.scope ?? ActionScope.GLOBAL;
		
		var state:LogicState = null;
		
		if (scopes.exists(scope))
		{
			state = scopes.get(scope);
		}
		else if (scope == ActionScope.GLOBAL)
		{
			state = LogicEvaluator.globalState;
		}
		else
		{
			trace('Error: Action targets unknown scope "$scope". Change ignored.');
			return;
		}

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