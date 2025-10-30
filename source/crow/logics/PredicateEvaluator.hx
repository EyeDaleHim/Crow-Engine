package crow.logics;

import crow.assets.metadata.logics.PredicateMetadata;
import crow.logics.PredicateOperatorCode;
import crow.logics.PredicateType;
import crow.logics.PredicateValidator;

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
	public static var validationLevel:PredicateValidatorLevel = REQUIRED;

	/**
	 * Evaluates a predicate against an entity's state and context.
	 * @param predicate The metadata defining the condition to evaluate. No predicate implies `true` (always passes).
	 * @param state The entity's state map (`Map<String, Dynamic>`).
	 * @return `true` if the condition is met, `false` otherwise.
	 */
	public static function evaluate(?predicate:PredicateMetadata, ?state:Map<String, Dynamic>):Bool
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
				if (predicate.operands == null)
					return true;
				for (operand in predicate.operands)
				{
					if (!evaluate(operand, state))
						return false;
				}
				return true;

			case OR:
				if (predicate.operands == null)
					return false;
				for (operand in predicate.operands)
				{
					if (evaluate(operand, state))
						return true;
				}
				return false;

			case NOT:
				if (predicate.operands == null || predicate.operands.length == 0)
					return true;
				return !evaluate(predicate.operands[0], state);

			case CHECK:
				return check(predicate, state);

			case RANGED_RANDOM:
				if (predicate.targetValues == null || predicate.targetValues.length < 4)
					return false;

				final minGen:Int = predicate.targetValues[0] ?? FlxMath.MIN_VALUE_INT;
				final maxGen:Int = predicate.targetValues[1] ?? FlxMath.MAX_VALUE_INT;
				final minCheck:Int = predicate.targetValues[2];
				final maxCheck:Int = predicate.targetValues[3];

				final randomValue = FlxG.random.int(minGen, maxGen);
				return randomValue >= minCheck && randomValue <= maxCheck;

			case LIST_CONTAINS:
				if (predicate.stateKey == null || predicate.targetValues == null || predicate.targetValues.length == 0)
					return false;

				final list:Array<Dynamic> = state.get(predicate.stateKey);
				if (list == null || !Std.isOfType(list, Array) || list.length == 0)
					return false;

				final valueToFind = predicate.targetValues[0];
				return list.indexOf(valueToFind) != -1;

			case STATE_COMPARE:
				if (predicate.stateKey == null || predicate.targetValues == null || predicate.targetValues.length == 0)
					return false;

				final value1 = state.get(predicate.stateKey);
				final value2 = state.get(predicate.targetValues[0]);

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

	private static function check(predicate:PredicateMetadata, state:Map<String, Dynamic>):Bool
	{
		var value:Dynamic = null;
		if (predicate.stateKey != null)
		{
			value = state.get(predicate.stateKey);
		}

		if (value == null || predicate.targetValues == null)
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
}

enum PredicateValidatorLevel
{
	/**
	 * Validation is required and the predicate will not be evaluated if it is invalid.
	 */
	REQUIRED;

	/**
	 * Validation is optional, but a warning will be issued if the predicate is invalid.
	 */
	WARN;

	/**
	 * No validation is performed.
	 */
	NONE;
}
