package crow.assets.metadata.logics;

import crow.logics.tools.ActionChangeType;
import crow.logics.tools.ActionScope;

typedef ActionMetadata =
{
	// Defines the change type: "SET", "INCREMENT", "TOGGLE"
	var changeType:ActionChangeType;

	// The state key to modify (e.g., "isToggled", "positionX")
	var stateKey:String;

	// The value to use/add/set (e.g., 1.0 for INCREMENT, "Walk" for SET)
	var ?value:Dynamic;

	// The scope of the state to modify. Can be "global" (default), "local", or "entity".
	var ?scope:ActionScope;
};
