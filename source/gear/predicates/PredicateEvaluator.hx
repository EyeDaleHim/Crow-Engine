package gear.predicates;

import gear.predicates.PredicateOperatorCode;
import gear.predicates.PredicateType;
import gear.assets.metadata.PredicateMetadata;
import gear.predicates.PredicateValidator;

/**
 * A utility class for evaluating predicate conditions defined by `PredicateMetadata`.
 */
class PredicateEvaluator
{
    /**
     * Requires predicates to be valid and type-safe before it is processed on-demand.
	 * 
	 * Disabling this will incurs some performance benefit.
     */
    public static var requireValidation:Bool = true;

	/**
	 * Evaluates a predicate against an entity's state and context.
	 * @param predicate The metadata defining the condition to evaluate.
	 * @param state The entity's state map (`Map<String, Dynamic>`).
	 * @return `true` if the condition is met, `false` otherwise.
	 */
	public static function evaluate(predicate:PredicateMetadata, state:Map<String, Dynamic>):Bool
	{
		if (predicate == null)
			return true;
		
		if (requireValidation)
		{
			if (!PredicateValidator.validate(predicate))
				return false; // If validation fails, the predicate cannot be evaluated.
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

			default:
                return true;
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