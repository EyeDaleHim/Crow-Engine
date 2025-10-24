package gear.assets.metadata;

import gear.assets.metadata.AnimationMetadata;
import gear.utils.AxeData;
import gear.assets.metadata.ActionMetadata;
import gear.assets.metadata.PredicateMetadata;

typedef EntityMetadata =
{
	/**
	 * The name for this entity.
	 */
	var name:String;

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
	 * The scroll factor of this sprite.
	 * 
	 * Default is (1, 1) which implies it scrolls at the same rate as the camera.
	 */
	var ?scrollFactor:AxeData<Float>;

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
	 * 
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
 */
typedef ListenerActionMetadata = {
	/**
	 * The type of action to perform.
	 * 
	 * Example: "play_animation", "state_change"
	 */
	var type:String;

	/**
	 * The name of the sprite to target with this action.
	 * Required for sprite-specific actions like "play_animation".
	 */
	var ?sprite:String;

	/**
	 * For "state_change" actions, this defines the modification to perform.
	 */
	var ?stateChange:ActionMetadata;

	/**
	 * A list of values/arguments for the action. The interpretation
	 * of these values depends on the action `type`.
	 * 
	 * For "play_animation", this is the animation name: `["animationName"]`.
	 */
	var ?values:Array<String>;

	/**
	 * For "play_animation", if true, the animation will restart if it's already playing.
	 */
	var ?force:Bool;
};
