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
	 * This is a shorthand for `events[0]`.
	 * If `events` is also defined, `events` takes precedence.
	 * 
	 * Examples: "beat", "update", "create"
	 */
	var ?event:String;

	/**
	 * The list of events to listen for.
	 * If this is defined, it overrides the `event` field.
	 * 
	 * Examples: ["beat", "update", "create"]
	 */
	var ?tags:Array<String>;

	/**
	 * The list of events to listen for.
	 * If this is defined, it overrides the `event` field.
	 */
	var ?events:Array<String>;
	/**
	 * A condition that must be met for the actions to be triggered.
	 * This condition must return true for all `actions` to trigger.
	 */
	var ?condition:PredicateMetadata;

	/**
	 * If true, this listener will be removed after its actions are executed once.
	 * 
	 * The removal comes after all listeners are processed.
	 */
	var ?weak:Bool;

	/**
	 * The list of actions to perform when the event is triggered.
	 */
	var ?actions:Array<ListenerActionMetadata>;
};

/**
 * Defines a filter to select entities for an action.
 * If omitted, the action applies to all relevant entities.
 */
typedef EntityFilterMetadata =
{
	/**
	 * Filter by entity type (e.g., "Sprite", "Text", "Group").
	 * If this field is omitted, entities of any type can be selected.
	 */
	var ?type:String;

	/**
	 * Filter by a specific tag assigned to the entity.
	 * If this field is omitted, entities with any tag or no tag can be selected.
	 */
	var ?tag:String;

	/**
	 * Filter by a specific name assigned to the entity.
	 * If this field is omitted, entities with any name can be selected.
	 */
	var ?name:String;
}

/**
 * Defines an action to be performed by an event listener.
 */
typedef ListenerActionMetadata =
{
	var type:String; // e.g., "play_animation", "state_change"

	/**
	 * The tags for this listener to be identified as.
	 */
	var ?tags:Array<String>;

	/**
	 * Defines a filter to select entities for this action.
	 * If omitted, the action applies to all entities.
	 * 
	 * The order of filters matter as each filter uses the list of candidates from the
	 * last filter to narrow down the selection. This can often be a point
	 * of confusion for some users, but an important simplification is to see `targets` as
	 * a sequential filter, not a parallel one.
	 */
	var ?targets:Array<EntityFilterMetadata>; // Filter for the action (e.g., by type, tag, or name).

	/**
	 * Defines a list of actions to be performed after all listeners are processed.
	 * This is useful for triggering follow-up events or state changes that
	 * depend on the outcome of all listeners in the current event cycle.
	 * 
	 * If the `type` is asynchronous (e.g. a tween or a timer),
	 * which will trigger if the tween or timed event is completed.
	 * If the `type` is not asynchronous, all events in `postListenerEvents` get executed
	 * immediately, it's better to use `actions` instead.
	 */
	var ?postListenerEvents:Array<ListenerActionMetadata>;

	var ?values:Array<Dynamic>; // Arguments, e.g., animation name, state change data
};
