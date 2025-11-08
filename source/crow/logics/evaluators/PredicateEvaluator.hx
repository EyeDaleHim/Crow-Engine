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
	 * Evaluates a predicate against an entity's state and context.
	 * @param predicate The metadata defining the condition to evaluate. No predicate implies `true` (always passes).
	 * @param globalState The primary state map.
	 * @param localState An optional secondary, temporary state map.
	 * @param entityState An optional entity-specific state map.
	 * @return `true` if the condition is met, `false` otherwise.
	 */
	public static function evaluate(?predicate:PredicateMetadata, ?globalState:LogicState, ?localState:LogicState, ?entityState:LogicState):Bool
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
					if (!evaluate(operand, globalState, localState, entityState))
						return false;
				}
				return true;

			case OR:
				for (operand in predicate.operands)
				{
					if (evaluate(operand, globalState, localState, entityState))
						return true;
				}
				return false;

			case NOT:
				return !evaluate(predicate.operands[0], globalState, localState, entityState);

			case CHECK:
				return check(predicate, globalState, localState, entityState);

			case RANGED_RANDOM:
				final minGen:Int = predicate.targetValues[0] ?? FlxMath.MIN_VALUE_INT;
				final maxGen:Int = predicate.targetValues[1] ?? FlxMath.MAX_VALUE_INT;
				final minCheck:Int = predicate.targetValues[2];
				final maxCheck:Int = predicate.targetValues[3];

				final randomValue = FlxG.random.int(minGen, maxGen);
				return randomValue >= minCheck && randomValue <= maxCheck;

			case LIST_CONTAINS:
				final state = getStateFromScope(predicate.scope, globalState, localState, entityState);

				final list:Array<Dynamic> = state.get(predicate.stateKey);
				if (list == null || list.length == 0)
					return false;

				final valueToFind = predicate.targetValues[0];
				return list.indexOf(valueToFind) != -1;

			case STATE_COMPARE:
				final state1 = getStateFromScope(predicate.scope, globalState, localState, entityState);
				// The second value for comparison can also have a scope, but for now we assume it's a key in the same scope.
				final state2 = state1;

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

	private static function check(predicate:PredicateMetadata, globalState:LogicState, localState:LogicState, entityState:LogicState):Bool
	{
		final state = getStateFromScope(predicate.scope, globalState, localState, entityState);
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

	private static function getStateFromScope(?scope:ActionScope, globalState:LogicState, localState:LogicState, entityState:LogicState):LogicState
	{
		final scopeStr = scope ?? GLOBAL;
		return switch (scopeStr)
		{
			case LOCAL:
				localState;
			case ENTITY:
				entityState;
			case GLOBAL:
				globalState;
			default:
				trace('Warning: Unknown scope "${scopeStr}" in predicate. Defaulting to global.');
				globalState;
		}
	}
}
