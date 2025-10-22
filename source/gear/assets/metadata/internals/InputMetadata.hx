package gear.assets.metadata.internals;

import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfThree;

/**
 * Defines the structure for the default input bindings configuration file.
 * This metadata is loaded at startup to establish the initial state of all game inputs,
 * which can later be overridden by player-specific save data.
 */
typedef InputMetadata =
{
	/**
	 * An array of all bindable actions in the game.
	 */
	var binds:Array<ActionBind>;
};

/**
 * Represents a single bindable action, like "jump" or "ui_accept".
 * An action can be triggered by one or more `InputTrigger`s.
 */
typedef ActionBind =
{
	/**
	 * The unique identifier for this action. This is used by the game logic
	 * to query the input state (e.g., `Input.isPressed("jump")`).
     * 
     * If the game cannot find the input of this id, every case will return
     * false.
	 */
	var id:String;

	/**
	 * A list of triggers that can activate this action. Having multiple triggers
	 * allows for primary and alternate keybindings.
	 */
	var triggers:Array<InputTrigger>;
};

/**
 * Defines a specific set of conditions for an `ActionBind` to be activated.
 * This can be a simple key press, a combination of keys, a held input, etc.
 */
typedef InputTrigger =
{
	/**
	 * A list of one or more inputs that must be active simultaneously.
	 * A single entry represents a simple key press. Multiple entries represent a combo
	 * (e.g., ["Control", "S"]) or a hybrid mash (e.g., Keyboard "Alt" + Mouse "LMB").
	 */
	var inputs:Array<InputSource>;

	/**
	 * If `true` for a combo, the inputs must be pressed in the exact order they are defined in the `inputs` array.
	 * Defaults to `false`.
	 */
	var ?orderSensitive:Bool;

	/**
	 * If `true`, this trigger will only activate if no other inputs are currently held down.
	 * This is useful for preventing accidental activations, e.g., triggering "Dash" (Shift) when trying to "Sprint-Jump" (Shift + Space).
	 * The check resets when all keys are released.
	 * Defaults to `false`.
	 */
	var ?exclusive:Bool;

	/**
	 * Defines the condition for a combo to be considered "just released".
	 * - `"ANY"`: The combo is "just released" if any of its keys are released while the combo was active. (Default)
	 * - `"LAST"`: The combo is "just released" only if the last key in an `orderSensitive` sequence is released while the others are held.
	 * This field is only relevant for combos (triggers with more than one input). Defaults to "ANY".
	 */
	var ?comboRelease:String; // "ANY" or "LAST"
};

/**
 * Represents a single physical input from a device.
 */
typedef InputSource =
{
	var device:String; // "keyboard", "mouse", "virtual"
	var code:String; // e.g., "A", "SPACE", "LMB",
}
