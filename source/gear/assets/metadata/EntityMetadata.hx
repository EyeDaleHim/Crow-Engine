package gear.assets.metadata;

import gear.assets.metadata.AnimationMetadata;
import gear.utils.AxeData;

typedef EntityMetadata =
{
	/**
	 * The name for this entity.
	 */
	var name:String;

	/**
	 * The position of this entity.
	 */
	var position:AxeData<Float>;

	/**
	 * The list of sprites for this entity to render.
	 * 
	 * Rendering order depends on the order of elements in this array.
	 */
	var sprites:Array<SpriteMetadata>;

	/**
	 * The list of listeners for this entity.
     * 
     * This can be anything like on-beat events to the music, etc.
	 */
    var ?listeners:Array<EntityListenerMetadata>;

	/**
	 * A map of initial state variables for this entity.
	 * These can be checked and modified by listeners.
	 */
	var ?initialState:Dynamic;
};

typedef SpriteMetadata =
{
	/**
	 * The name of the sprite.
	 */
	var name:String;

	/**
	 * The path to the sprite's image file.
	 */
	var assetPath:String;

	/**
	 * Whether or not this sprite uses an atlas. The default value
	 * is false.
	 */
	var ?usingAtlas:Bool;

	/**
	 * The metadata for the sprite's animation. Has no effect if
	 * usingAtlas is false.
	 */
	var ?animations:Array<AnimationMetadata>;

	/**
	 * The position of this sprite relative to its parent entity.
	 */
	var position:AxeData<Float>;

	/**
	 * The scale of this sprite. Width and height will be updated.
	 */
    var ?scale:AxeData<Float>;

	/**
	 * The rotation of this sprite, in degrees.
	 */
    var ?angle:Float;
};

/**
 * Defines a listener for a specific event on an entity.
 */
typedef EntityListenerMetadata = {
	/**
	 * The event to listen for.
	 * 
	 * Examples: "beat", "update", "create"
	 */
	var event:String;

	/**
	 * A condition that must be met for the actions to be triggered.
	 */
	var ?condition:ListenerConditionMetadata;

	/**
	 * The list of actions to perform when the event is triggered.
	 */
	var actions:Array<ListenerActionMetadata>;
};

/**
 * Defines an action to be performed by an event listener.
 */
typedef ListenerActionMetadata = {
	/**
	 * The type of action to perform.
	 * 
	 * Example: "play_animation"
	 */
	var type:String;

	/**
	 * The name of the sprite to target with this action.
	 * If null, this does nothing.
	 */
	var ?sprite:String;

	/**
	 * The type of state modification to perform.
	 * Example: "toggle_bool"
	 */
	var ?stateChange:String;

	/**
	 * A list of values/arguments for the action. The interpretation
	 * of these values depends on the action `type`.
	 * 
	 * For "play_animation", this could be a list of animation names to cycle through.
	 */
	var ?values:Array<String>;

	/**
	 * If true, the action will force the animation to restart if it's already playing.
	 */
	var ?force:Bool;
};


// Ideally, I should make a predicate system instead of having this.
/**
 * Defines a condition for an event listener.
 */
typedef ListenerConditionMetadata = {
	/**
	 * The type of condition to check.
	 * 
	 * Example: "beat_modulo"
	 */
	var ?type:String;

	/**
	 * The value(s) to use for the condition check.
	 * For "beat_modulo", this would be `[divisor, remainder]`.
	 */
	var ?value:Array<Int>;

	/**
	 * Checks a state variable on the entity.
	 */
	var ?checkState:String;
};
