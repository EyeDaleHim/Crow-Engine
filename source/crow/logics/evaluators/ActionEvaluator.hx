package crow.logics.evaluators;

import crow.assets.metadata.logics.ActionMetadata;
import crow.logics.dependencies.LogicContext;
import crow.logics.dependencies.LogicState;
import crow.logics.tools.ActionScope;
import crow.logics.tools.ValidatorLevel;
import crow.logics.validators.ActionValidator;

class ActionEvaluator
{
	public static var validationLevel:ValidatorLevel = REQUIRED;

	public static function evaluate(action:ActionMetadata, context:ILogicContext):Void
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
		final state = context.getState(scope);

		if (state == null)
		{
			trace('ActionEvaluator: Scope "$scope" not found in context.');
			return;
		}

		switch (action.changeType)
		{
			case SET:
				state.set(action.stateKey, action.value);
			case INCREMENT, DECREMENT:
				untyped final change:Int = (action.changeType == INCREMENT) ? action.value : -action.value;
				state.set(action.stateKey, state.get(action.stateKey) + change);
			case ADD, SUBTRACT:
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
