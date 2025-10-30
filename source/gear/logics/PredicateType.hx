package gear.logics;

/**
 * Defines the types of logical operations for predicates.
 */
enum abstract PredicateType(String) to String
{
	var AND = "AND";
	var OR = "OR";
	var NOT = "NOT";
	var CHECK = "CHECK";

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
			default: null;
		}
	}
}
