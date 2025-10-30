package crow.assets.metadata.logics;

typedef PredicateMetadata =
{
	// The type of logical operation this node represents: "AND", "OR", "NOT", "CHECK"
	var type:String;

	// For "AND", "OR", "NOT": a list of nested PredicateMetadata.
	var ?operands:Array<PredicateMetadata>;

	// For "CHECK": The field to check on the entity's state.
	var ?stateKey:String;

	// For "CHECK": The comparison operator: "EQ", "NEQ", "GT", "LT", "MODULO", etc.
	var ?operatorCode:String;

	// For "CHECK": The value(s) to compare against.
	var ?targetValues:Array<Dynamic>;
};
