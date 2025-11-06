package crow.assets.metadata.menus;

import crow.assets.metadata.game.EntityMetadata;
import crow.assets.metadata.logics.LogicMetadata;
import crow.assets.metadata.logics.PredicateMetadata;
import crow.utils.AxeData;
import crow.objects.layout.LayoutProperties;

/**
 * The base structure for menu layouts and input handling.
 */
typedef MenuMetadata =
{
	/**
	 * The layout properties for the top-level menu.
	 */
	var ?layout:MenuLayout;

	/**
	 * A list of elements to be displayed in the menu, including both interactive items and decorations.
	 * The logic for how these are displayed and interacted with
	 * is handled by the state that loads this metadata.
	 */
	var ?elements:Array<MenuItem>;

	/**
	 * A map of custom data to be stored and processed.
	 */
	var ?storedData:Dynamic;

	/**
	 * Defines actions to be taken on specific inputs.
	 * This allows for data-driven control flow.
	 */
	var ?inputActions:Array<MenuInput>;

	/**
	 * Defines asset contexts to be loaded or unloaded with the menu.
	 */
	var ?contexts:MenuContexts;

	/**
	 * Logic properties for the menu, including initial state and listeners.
	 */
	var ?logic:LogicMetadata;
	
	/**
	 * Defines how transitions are handled for a menu state.
	 */
	var ?transitions:MenuTransitions;
};

/**
 * Defines how transitions are handled for a menu state.
 * If a field is `true`, the corresponding transition will be skipped.
 * If `false` or `null`, the transition will play.
 */
typedef MenuTransitions =
{
	/**
	 * If `true`, skips the transition when the state is first entered.
	 */
	var ?skipIn:Bool;
	/**
	 * If `true`, skips the transition when returning to this state from a sub-state.
	 */
	var ?skipReturn:Bool;
	/**
	 * If `true`, skips the transition when leaving this state.
	 */
	var ?skipOut:Bool;
};

/**
 * Represents a single item within a menu.
 */
typedef MenuItem =
{
	/**
	 * The name or identifier for this menu item.
	 * 
	 * There are special names like "_root_layout", it is considered a "special item",
	 * where instead of creating/using an entity, the special item will simply
	 * be re-ordered in the state's `members` array using this item's index as reference.
	 * 
	 * By default, "_root_layout" is always added before any `elements`, if any item
	 * does not present "_root_layout".
	 * 
	 * If `name` is identified as a "special item", all other fields, except for `position` and `screenCenter`,
	 * are ignored.
	 */
	var name:String; // e.g., "story_mode", "freeplay"

	/**
	 * The path to an entity file that represents this menu item visually.
	 * If provided, the menu will create an `Entity` from this asset path.
	 * This allows for animated or complex menu items.
	 */
	var ?entity:String; // e.g., "menus/items/story_mode_button"

	/**
	 * Allows overriding specific properties of the entity metadata defined in the `entity` field.
	 * This is useful for making minor adjustments to an entity without creating a new metadata file.
	 */
	var ?overrideData:EntityMetadata;

	/**
	 * An action to be triggered when this item is accepted.
	 */
	var ?onAccept:MenuAction;

	/**
	 * An action to be triggered when this item is selected.
	 */
	var ?onSelect:MenuAction;

	/**
	 * An action to be triggered when this item is deselected.
	 */
	var ?onDeselect:MenuAction;

	/**
	 * An action to be triggered when the layout's index changes in general.
	 */
	var ?onIndex:MenuAction;

	/**
	 * The layout properties for this item's children, if it is a sub-menu.
	 */
	var ?layout:MenuLayout;

	/**
	 * A list of child items, turning this item into a sub-menu or group.
	 * If this is present, `entity` and `onAccept` are typically ignored,
	 * as this item becomes a container.
	 */
	var ?items:Array<MenuItem>;

	/**
	 * The alignment of this specific item within its parent layout.
	 * This overrides the parent layout's `alignItems` property.
	 */
	var ?alignSelf:AlignItems;

	/**
	 * An optional position to place the entity, overriding its default and any layout calculations.
	 */
	var ?position:AxeData<Float>;

	/**
	 * If true, the entity will be centered on the screen.
	 * This overrides the `position` property for the specified axes.
	 */
	var ?screenCenter:AxeData<Bool>;
};

/**
 * Defines the layout properties for a menu or a sub-menu.
 */
typedef MenuLayout =
{
	/**
	 * The direction in which items are laid out (e.g., `VERTICAL` or `HORIZONTAL`).
	 */
	var ?direction:LayoutDirection;
	/**
	 * The amount of space between each item in the layout.
	 */
	var ?gap:Float;
	/**
	 * The padding around the entire layout.
	 */
	var ?padding:Float;
	/**
	 * How items are distributed along the main axis.
	 */
	var ?justifyContent:JustifyContent;
	/**
	 * How items are aligned along the cross axis.
	- */
	var ?alignItems:AlignItems;
	/**
	 * Whether items should wrap to the next line if they exceed the layout's size.
	 */
	var ?wrap:FlexWrap;

	/**
	 * The behavior of the gap between items.
	 */
	var ?gapBehavior:GapBehavior;

	/**
	 * If true, the layout will automatically resize to fit its content.
	 * Defaults to true.
	 */
	var ?autoSize:Bool;

	/**
	 * The selection mode for an interactable layout.
	 */
	var ?selectionMode:SelectionMode;

	/**
	 * An action to be triggered when an item in this layout is selected.
	 */
	var ?onSelect:MenuAction;

	/**
	 * An action to be triggered when an item in this layout is deselected.
	 */
	var ?onDeselect:MenuAction;

	/**
	 * An action to be triggered when the layout's selection index changes.
	 */
	var ?onIndex:MenuAction;
};

/**
 * Defines asset contexts to be loaded or unloaded with the menu.
 * These are processed by the state that loads the menu metadata.
 */
typedef MenuContexts =
{
	/**
	 * A list of asset context names to load when the menu is created.
	 */
	var ?load:Array<String>;

	/**
	 * A list of asset context names to unload when the menu is destroyed.
	 */
	var ?unload:Array<String>;
};

/**
 * Maps a game input to a specific action.
 */
typedef MenuInput =
{
	/**
	 * The input ID to check, as defined in the input configuration.
	 * e.g., "accept", "back", "ui_up", "ui_down"
	 */
	var input:String; // e.g., "accept", "back", "up", "down"

	/**
	 * A list of actions to perform when the input condition is met.
	 */
	var ?actions:Array<MenuAction>;

	/**
	 * The tags for this input action to be identified as.
	 */
	var ?tags:Array<String>;

	/**
	 * The type of input check to perform. Defaults to `JustPressed`.
	 */
	var ?check:MenuInputCheck;

	/**
	 * An optional condition that must be met for this input to be processed.
	 * The condition is evaluated against the menu's `logicState`.
	 */
	var ?condition:PredicateMetadata;
};

/**
 * Defines an action to be performed within a menu.
 */
typedef MenuAction =
{
	/**
	 * The type of action to perform.
	 * Examples: "navigate", "accept_selection", "open_state", "close_menu", "dispatch_event"
	 */
	var type:String;

	/**
	 * Arguments for the action.
	 */
	var ?values:Dynamic;
};

enum abstract MenuInputCheck(String) from String to String
{
	/** Triggers once when the input is first pressed. */
	var JustPressed = "just_pressed";

	/** Triggers continuously while the input is held down. */
	var Pressed = "pressed";

	/** Triggers once when the input is released. */
	var JustReleased = "just_released";

	/** Triggers continuously while the input is not held down (is up). */
	var Released = "released";
}
