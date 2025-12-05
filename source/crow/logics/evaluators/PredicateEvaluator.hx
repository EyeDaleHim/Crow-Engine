package crow.logics.evaluators;

import crow.assets.metadata.logics.PredicateMetadata;
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
	 * Evaluates a predicate against a context of logic states.
	 * 
	 * @param predicate The metadata defining the condition to evaluate. No predicate implies `true` (always passes).
	 * @param scopes A map of available LogicStates keyed by their scope name (e.g. "local", "entity", "settings").
	 * @return `true` if the condition is met, `false` otherwise.
	 */
	public static function evaluate(?predicate:PredicateMetadata, scopes:Map<String, LogicState>):Bool
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
					if (!evaluate(operand, scopes))
						return false;
				}
				return true;

			case OR:
				for (operand in predicate.operands)
				{
					if (evaluate(operand, scopes))
						return true;
				}
				return false;

			case NOT:
				return !evaluate(predicate.operands[0], scopes);

			case CHECK:
				return check(predicate, scopes);

			case RANGED_RANDOM:
				final minGen:Int = predicate.targetValues[0] ?? FlxMath.MIN_VALUE_INT;
				final maxGen:Int = predicate.targetValues[1] ?? FlxMath.MAX_VALUE_INT;
				final minCheck:Int = predicate.targetValues[2];
				final maxCheck:Int = predicate.targetValues[3];

				final randomValue = FlxG.random.int(minGen, maxGen);
				return randomValue >= minCheck && randomValue <= maxCheck;

			case LIST_CONTAINS:
				final state = getStateFromScope(predicate.scope, scopes);

				final list:Array<Dynamic> = state.get(predicate.stateKey);
				if (list == null || list.length == 0)
					return false;

				final valueToFind = predicate.targetValues[0];
				return list.indexOf(valueToFind) != -1;

			case STATE_COMPARE:
				final state1 = getStateFromScope(predicate.scope, scopes);
				// The second value for comparison has its own scope, defaulting to the first value's scope if not provided.
				final state2 = getStateFromScope(predicate.targetScope ?? predicate.scope, scopes);
				
				final value1 = state1.get(predicate.stateKey);
				final value2 = state2.get(predicate.targetValues[0]);

				if (value1 == null || value2 == null)
					return false;

				return switch (predicate.operatorCode)
				{
					case EQ: value1 == value2;
					case NEQ: value1 != value2;
					case GT: value1 > value2;
					case LT: value1 < value2;
					case GTE: value1 >= value2;
					case LTE: value1 <= value2;
					default: false;
				}

			default:
				return false;
		}
	}

	private static function check(predicate:PredicateMetadata, scopes:Map<String, LogicState>):Bool
	{
		final state = getStateFromScope(predicate.scope, scopes);
		final value:Dynamic = state.get(predicate.stateKey);

		// `value` can be null if the state doesn't exist, which is a valid check (e.g., `key == null`).
		if (predicate.targetValues == null)
			return false;

		return switch (predicate.operatorCode)
		{
			case EQ: value == predicate.targetValues[0];
			case NEQ: value != predicate.targetValues[0];
			case GT: value > predicate.targetValues[0];
			case LT: value < predicate.targetValues[0];
			case GTE: value >= predicate.targetValues[0];
			case LTE: value <= predicate.targetValues[0];
			case MODULO: (Std.int(value) % predicate.targetValues[0]) == predicate.targetValues[1];
			default: false;
		}
	}

	/**
	 * Retrieves the LogicState for a given scope string.
	 * If the scope is not found in the provided map, or is explicitly "global", 
	 * it defaults to LogicEvaluator.globalState.
	 */
	private static function getStateFromScope(scope:String, scopes:Map<String, LogicState>):LogicState
	{
		// Default to global if undefined
		if (scope == null) 
			scope = ActionScope.GLOBAL;

		// 1. Try to find the scope in the provided map
		if (scopes != null && scopes.exists(scope))
		{
			return scopes.get(scope);
		}

		// 2. Fallback: If scope is "global" (or we failed to find it above), use the static global state.
		// This prevents the developer from having to manually insert LogicEvaluator.globalState into the map every time.
		if (scope == ActionScope.GLOBAL)
		{
			return LogicEvaluator.globalState;
		}

		trace('Warning: Unknown scope "${scope}" requested and not found in context. Defaulting to LogicEvaluator.globalState.');
		return LogicEvaluator.globalState;
	}
}