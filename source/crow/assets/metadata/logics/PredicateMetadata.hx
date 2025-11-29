package crow.assets.metadata.logics;

import crow.logics.tools.ActionScope;

typedef PredicateMetadata =
{
	// The type of logical operation this node represents: "AND", "OR", "NOT", "CHECK"
	var type:String;

	// For "AND", "OR", "NOT": a list of nested PredicateMetadata.
	var ?operands:Array<PredicateMetadata>;

	// The scope of the state to check. Can be "global" (default), "local", or "entity".
	var ?scope:String;

	// For "CHECK": The field to check on the entity's state.
	var ?stateKey:String;

	// For "CHECK": The comparison operator: "EQ", "NEQ", "GT", "LT", "MODULO", etc.
	var ?operatorCode:String;

	// For "STATE_COMPARE": The scope of the target value for comparison.
	var ?targetScope:ActionScope;

	// For "CHECK": The value(s) to compare against.
	var ?targetValues:Array<Dynamic>;
}
