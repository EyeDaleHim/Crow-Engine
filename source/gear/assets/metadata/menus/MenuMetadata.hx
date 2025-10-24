package gear.assets.metadata.menus;

import gear.utils.AxeData;
import gear.objects.layout.LayoutProperties;
import gear.assets.metadata.logics.LogicMetadata;

/**
 * The base structure for menu layouts and input handling.
 * This can be extended by more specific menu metadata types.
 */
typedef MenuMetadata =
{
	/**
	 * The layout properties for the top-level menu.
	 */
	var ?layout:MenuLayout;

	/**
	 * A list of items to be displayed in the menu.
	 * The logic for how these are displayed and interacted with
	 * is handled by the state that loads this metadata.
	 */
	var ?items:Array<MenuItem>;

	/**
	 * A list of decorative entities to display. These are not part of the
	 * interactive layout and are purely for visual effect.
	 */
	var ?decorations:Array<MenuDecoration>;

	/**
	 * Defines actions to be taken on specific inputs.
	 * This allows for data-driven control flow.
	 */
	var ?inputActions:Array<MenuInput>;

	/**
	 * Logic properties for the menu, including initial state and listeners.
	 */
	var ?logic:LogicMetadata;
};

/**
 * Represents a single item within a menu.
 */
typedef MenuItem =
{
	/**
	 * The name or identifier for this menu item.
	 */
	var name:String; // e.g., "story_mode", "freeplay"

	/**
	 * The path to an entity file that represents this menu item visually.
	 * If provided, the menu will create an `Entity` from this asset path.
	 * This allows for animated or complex menu items.
	 */
	var ?entity:String; // e.g., "menus/items/story_mode_button"

	/**
	 * An action to be triggered when this item is selected/accepted.
	 */
	var ?onAccept:MenuAction;

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
};

/**
 * Represents a decorative entity within a menu scene.
 */
typedef MenuDecoration =
{
	/**
	 * The path to the entity file to load.
	 */
	var entity:String;

	/**
	 * An optional position to place the entity, overriding its default.
	 */
	var ?position:AxeData<Float>;
	
	/**
	 * If true, the entity will be centered on the screen.
	 * This overrides any `position` property.
	 */
	var ?screenCenter:AxeData<Bool>;
};

/**
 * Defines the layout properties for a menu or a sub-menu.
 */
typedef MenuLayout =
{
	var ?direction:LayoutDirection;
	var ?gap:Float;
	var ?padding:Float;
	var ?justifyContent:JustifyContent;
	var ?alignItems:AlignItems;
	var ?wrap:FlexWrap;

	/**
	 * The behavior of the gap between items.
	 */
	var ?gapBehavior:GapBehavior;
};

/**
 * Maps a game input to a specific action.
 */
typedef MenuInput =
{
	var input:String; // e.g., "accept", "back", "up", "down"
	var action:MenuAction;
};

/**
 * Defines an action to be performed within a menu.
 */
typedef MenuAction =
{
	/**
	 * The type of action to perform.
	 * Examples: "navigate", "accept_selection", "open_state", "close_menu"
	 */
	var type:String;

	/**
	 * An array of arguments for the action.
     * 
     * For developers, it is up to you to code in the logic for these arguments.
	 */
	var ?args:Array<Dynamic>;
};
