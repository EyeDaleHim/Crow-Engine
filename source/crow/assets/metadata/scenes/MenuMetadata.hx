package crow.assets.metadata.scenes;

import crow.assets.metadata.game.EntityMetadata;
import crow.assets.metadata.logics.LogicMetadata;
import crow.assets.metadata.logics.PredicateMetadata;
import crow.assets.metadata.scenes.SceneMetadata;
import crow.utils.AxeData;
import crow.objects.layout.LayoutProperties;

/**
 * The base structure for menu layouts and input handling.
 */
typedef MenuMetadata =
{
	> SceneMetadata,

	/**
	 * A list of layout properties for the menu.
	 */
	var ?layouts:Array<MenuLayout>;

	/**
	 * A list of generic elements that can be reused and customized.
	 */
	var ?genericElements:Array<GenericMenuItem>;

	/**
	 * A list of elements to be displayed in the menu, including both interactive items and decorations.
	 * The logic for how these are displayed and interacted with
	 * is handled by the state that loads this metadata.
	 */
	var ?elements:Array<MenuItem>;

	/**
	 * Defines actions to be taken on specific inputs.
	 * This allows for data-driven control flow.
	 */
	var ?inputActions:Array<MenuInput>;
};

/**
 * Represents a generic menu item that can be reused and customized.
 */
typedef GenericMenuItem =
{
	/**
	 * The name of this generic item.
	 * 
	 * If the menu item inheriting this item does not have a name,
	 * this `name` will be used.
	 */
	var name:String;

	/**
	 * The menu item to be used as a template. Fields like `template`
	 * are ignored.
	 */
	var menuItem:MenuItem;

	/**
	 * If a menu item uses this generic item and it has its own
	 * `listeners` fields. This boolean determines if the generic 
	 * item's listeners should be appended to the specific item's 
	 * listeners, rather than overwriting them.
	 * 
	 * If `false` (default), the specific item's listeners will overwrite the 
	 * generic item's listeners.
	 */
	var ?listenerAppends:Bool;
};

/**
 * Represents a single item within a menu.
 */
typedef MenuItem =
{
	/**
	 * If defined, this menu item will inherit properties from a generic menu item.
	 * The `name` field of the generic item will be used to identify it.
	 */
	var ?genericReference:String;

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
	 * 
	 * If `name` is not defined but `entity` is defined and this item will be unified as an entity,
	 * then the `name` will be automatically assigned to the entity's `entityName`.
	 * 
	 * In all undefined cases, `name` will be a randomly generated UUID.
	 */
	var ?name:String; // e.g., "story_mode", "freeplay"

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
	 * The list of listeners for events.
	 * This can be anything like on-beat events to the music, etc.
	 */
	var ?listeners:Array<ListenerMetadata>;

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

	/**
	 * The name of the camera this item belongs to.
	 * 
	 * If undefined, `FlxG.camera` will be used.
	 */
	var ?camera:String;

	/**
	 * If defined, this item acts as a template generator. 
	 * The menu will create a copy of this item for every entry found in the specified data source.
	 */
	var ?dataSource:MenuDataSource;

	/**
	 * If using `dataSource`, this filter allows narrowing down the list 
	 * (e.g., the ID of a playlist or a specific LevelGroup ID to get levels from).
	 */
	var ?dataFilter:String;
};

/**
 * Defines the layout properties for a menu or a sub-menu.
 */
typedef MenuLayout =
{
	/**
	 * The name of the layout, used to identify it for actions like navigation.
	 */
	var ?name:String;

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
	var ?onSelect:ListenerActionMetadata;

	/**
	 * An action to be triggered when an item in this layout is deselected.
	 */
	var ?onDeselect:ListenerActionMetadata;

	/**
	 * An action to be triggered when the layout's selection index changes.
	 */
	var ?onIndex:ListenerActionMetadata;
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
	var ?actions:Array<ListenerActionMetadata>;

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

enum abstract MenuDataSource(String) from String to String
{
	/**
	 * Generates an item for every LevelGroup (Song) defined in the MasterList.
	 */
	var GROUPS = "GROUPS";

	/**
	 * Generates an item for every Level inside a specific Group (defined by `dataFilter`).
	 */
	var LEVELS = "LEVELS";

	/**
	 * Generates an item for every entry in a Playlist (defined by `dataFilter`).
	 */
	var PLAYLIST = "PLAYLIST";
}
