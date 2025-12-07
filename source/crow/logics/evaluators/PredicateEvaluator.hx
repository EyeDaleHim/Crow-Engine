package crow.logics.evaluators;

import crow.assets.metadata.logics.PredicateMetadata;
import crow.logics.dependencies.LogicContext;
import crow.logics.dependencies.LogicState;
import crow.logics.tools.ActionScope;
import crow.logics.tools.PredicateOperatorCode;
import crow.logics.tools.PredicateType;
import crow.logics.tools.ValidatorLevel;
import crow.logics.validators.PredicateValidator;

/**
 * A utility class for evaluating predicate conditions defined by `PredicateMetadata`.
 */
class PredicateEvaluator
{
	/**
	 * Requires predicates to be valid and type-safe before it is processed on-demand.
	 * 
	 * Disabling this will incur some performance benefit.
	 */
	public static var validationLevel:ValidatorLevel = REQUIRED;

	/**
	 * Legacy entry point. Wraps arguments into a LogicContext.
	 */
	public static function evaluate(?predicate:PredicateMetadata, ?globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):Bool
	{
		// If no global state is provided, use the static one from LogicEvaluator to maintain legacy behavior
		var gState = globalState ?? LogicEvaluator.globalState;
		
		var context = LogicContext.createLegacy(gState, localState, entityState);
		return evaluateContext(predicate, context);
	}

	/**
	 * Evaluates a predicate using a flexible LogicContext.
	 * @param predicate The metadata defining the condition to evaluate.
	 * @param context The context provider for looking up states.
	 * @return `true` if the condition is met, `false` otherwise.
	 */
	public static function evaluateContext(?predicate:PredicateMetadata, context:ILogicContext):Bool
	{
		if (predicate == null)
			return true;

		switch (validationLevel)
		{
			case REQUIRED:
				if (!PredicateValidator.validate(predicate))
					return false;
			case WARN:
				PredicateValidator.validate(predicate);
			case NONE:
		}

		return switch (predicate.type)
		{
			case AND:
				for (operand in predicate.operands)
				{
					if (!evaluateContext(operand, context))
						return false;
				}
				return true;

			case OR:
				for (operand in predicate.operands)
				{
					if (evaluateContext(operand, context))
						return true;
				}
				return false;

			case NOT:
				return !evaluateContext(predicate.operands[0], context);

			case CHECK:
				return check(predicate, context);

			case RANGED_RANDOM:
				final minGen:Int = predicate.targetValues[0] ?? FlxMath.MIN_VALUE_INT;
				final maxGen:Int = predicate.targetValues[1] ?? FlxMath.MAX_VALUE_INT;
				final minCheck:Int = predicate.targetValues[2];
				final maxCheck:Int = predicate.targetValues[3];

				final randomValue = FlxG.random.int(minGen, maxGen);
				return randomValue >= minCheck && randomValue <= maxCheck;

			case LIST_CONTAINS:
				final state = getStateFromContext(predicate.scope, context);

				final list:Array<Dynamic> = state?.get(predicate.stateKey);
				if (list == null || list.length == 0)
					return false;

				final valueToFind = predicate.targetValues[0];
				return list.indexOf(valueToFind) != -1;

			case STATE_COMPARE:
				final state1 = getStateFromContext(predicate.scope, context);
				// The second value for comparison has its own scope, defaulting to the first value's scope if not provided.
				final state2 = getStateFromContext(predicate.targetScope ?? predicate.scope, context);
				
				if (state1 == null || state2 == null)
					return false;

				final value1 = state1.get(predicate.stateKey);
				final value2 = state2.get(predicate.targetValues[0]);

				if (value1 == null || value2 == null)
					return false;

				return compareValues(value1, value2, predicate.operatorCode);

			default:
				return false;
		}
	}

	private static function check(predicate:PredicateMetadata, context:ILogicContext):Bool
	{
		final state = getStateFromContext(predicate.scope, context);
		if (state == null) 
			return false;

		final value:Dynamic = state.get(predicate.stateKey);

		// `value` can be null if the state doesn't exist, which is a valid check (e.g., `key == null`).
		if (predicate.targetValues == null)
			return false;

		return compareValues(value, predicate.targetValues[0], predicate.operatorCode, predicate.targetValues[1]);
	}

	private static function compareValues(val1:Dynamic, val2:Dynamic, op:PredicateOperatorCode, ?extra:Dynamic):Bool
	{
		return switch (op)
		{
			case EQ: val1 == val2;
			case NEQ: val1 != val2;
			case GT: val1 > val2;
			case LT: val1 < val2;
			case GTE: val1 >= val2;
			case LTE: val1 <= val2;
			case MODULO: (Std.int(val1) % val2) == extra;
			default: false;
		}
	}

	private static function getStateFromContext(scope:String, context:ILogicContext):LogicState
	{
		// We allow raw strings or the ActionScope enum string
		final foundState = context.getState(scope);
		
		if (foundState == null)
		{
			// Optional: Decide if we fall back to GLOBAL, or just return null and let the check fail.
			// Legacy behavior often implied global fallback, but strict scoping is cleaner.
			// Falling back to global for backward compat:
			if (scope == null || scope == "") 
				return context.getState(ActionScope.GLOBAL);
		}
		
		return foundState;
	}
}