package gear.assets.metadata.logics;

import gear.logics.ActionChangeType;

typedef ActionMetadata =
{
	// Defines the change type: "SET", "INCREMENT", "TOGGLE"
	var changeType:ActionChangeType;

	// The state key to modify (e.g., "isToggled", "positionX")
	var stateKey:String;

	// The value to use/add/set (e.g., 1.0 for INCREMENT, "Walk" for SET)
	var ?value:Dynamic;
};
