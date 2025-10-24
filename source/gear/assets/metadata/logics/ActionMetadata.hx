package gear.assets.metadata.logics;

typedef ActionMetadata =
{
	// Defines the change type: "SET", "INCREMENT", "TOGGLE", "CALL_SYSTEM_FUNCTION"
	var changeType:String;

	// The state key to modify (e.g., "isToggled", "positionX")
	var stateKey:String;

	// The value to use/add/set (e.g., 1.0 for INCREMENT, "Walk" for SET)
	var ?value:Dynamic;
};
