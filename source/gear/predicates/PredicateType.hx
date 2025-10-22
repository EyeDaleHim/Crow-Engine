package gear.predicates;

/**
 * Defines the types of logical operations for predicates.
 */
enum abstract PredicateType(String) to String
{
	var AND = "AND";
	var OR = "OR";
	var NOT = "NOT";
	var CHECK = "CHECK";
}
