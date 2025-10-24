package gear.assets.metadata.logics;

import gear.assets.metadata.logics.ActionMetadata;
import gear.assets.metadata.logics.PredicateMetadata;

/**
 * Defines a container for logic-related metadata, such as initial state
 * and event listeners. This can be included in other metadata types
 * like `MenuMetadata` or `StageMetadata` to add dynamic behavior.
 */
typedef LogicMetadata =
{
	/**
	 * A map of initial state variables.
	 * These can be checked and modified by listeners.
	 */
	var ?initialState:Dynamic;

	/**
	 * The list of listeners for events.
	 * This can be anything like on-beat events to the music, etc.
	 */
	var ?listeners:Array<ListenerMetadata>;
}

/**
 * Defines a listener for a specific event.
 */
typedef ListenerMetadata =
{
	/**
	 * The event to listen for.
	 * 
	 * Examples: "beat", "update", "create"
	 */
	var event:String;

	/**
	 * A condition that must be met for the actions to be triggered.
	 * This condition must return true for all `actions` to trigger.
	 */
	var ?condition:PredicateMetadata;

	/**
	 * The list of actions to perform when the event is triggered.
	 */
	var actions:Array<ListenerActionMetadata>;
};

/**
 * Defines an action to be performed by an event listener.
 * This was formerly `ListenerActionMetadata` inside `EntityMetadata`.
 */
typedef ListenerActionMetadata =
{
	var type:String; // e.g., "play_animation", "state_change"
	var ?sprite:String; // Target sprite for sprite-specific actions
	var ?stateChange:ActionMetadata; // For "state_change" actions
	var ?values:Array<String>; // Arguments, e.g., animation name
	var ?force:Bool; // For "play_animation", forces restart
};
