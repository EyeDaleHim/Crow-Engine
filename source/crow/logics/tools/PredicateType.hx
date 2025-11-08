package crow.logics.tools;

/**
 * Defines the types of logical operations for predicates.
 */
enum abstract PredicateType(String) to String
{
	// Static predicates

	/**
	 * Logical AND: All operands must be true.
	 */
	var AND = "AND";

	/**
	 * Logical OR: At least one operand must be true.
	 */
	var OR = "OR";

	/**
	 * Logical NOT: Negates the result of the operand.
	 */
	var NOT = "NOT";

	/**
	 * Evaluates a single condition based on a state key, operator, and target values.
	 */
	var CHECK = "CHECK";

	// Dynamic predicates
	/**
	 * Generates a random integer within a specified range and evaluates true/false 
	 * if it is within another specified range.
	 */
	var RANGED_RANDOM = "RANGED_RANDOM";

	/**
	 * Checks if a value exists within a list stored in the logic state.
	 * 
	 * Evaluates false if the list does not exist or is empty.
	 * Can also evaluate false if the list is somehow not a list.
	 */
	var LIST_CONTAINS = "LIST_CONTAINS";

	/**
	 * Compares two values from the logic state against each other.
	 * 
	 * Evaluates false if either of the state keys do not exist.
	 */
	var STATE_COMPARE = "STATE_COMPARE";

	@:from
	public static function fromString(value:String):PredicateType
	{
		if (value == null)
			return null;

		return switch (value.toUpperCase())
		{
			case "AND", "&&": AND;
			case "OR", "||": OR;
			case "NOT", "!": NOT;
			case "CHECK": CHECK;
			case "RANGED_RANDOM": RANGED_RANDOM;
			case "LIST_CONTAINS": LIST_CONTAINS;
			case "STATE_COMPARE": STATE_COMPARE;
			default: null;
		}
	}
}
