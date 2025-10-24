package gear.states.internals;

import gear.assets.metadata.menus.MenuMetadata;
import gear.objects.layout.InteractableLayout;
import gear.objects.layout.LayoutProperties;

/**
 * A base state for creating data-driven, interactive menus.
 * This class handles parsing menu metadata, building layouts, and processing input.
 */
class BaseMenuState extends MainState
{
	/**
	 * The root layout container for the entire menu.
	 */
	public var menuLayout:InteractableLayout;

	/**
	 * A map of all entities loaded for this menu, including decorations and items.
	 */
	public var menuEntities:Map<String, Entity> = [];

	/**
	 * The metadata that defines the structure and behavior of this menu.
	 */
	public var menuMetadata:MenuMetadata;

	public function new()
	{
		super();
	}

	/**
	 * Constructs the interactive menu from the loaded metadata.
	 * This is the main entry point for building the menu UI.
	 */
	public function buildMenu():Void
	{
		if (menuMetadata == null)
		{
			trace("Error: menuMetadata is null. Cannot build menu.");
			return;
		}

		if (menuMetadata.decorations != null)
		{
			buildDecorations(menuMetadata.decorations);
		}

		menuLayout = new InteractableLayout();
		add(menuLayout);

		if (menuMetadata.items != null)
		{
			buildLayoutFromItems(menuMetadata.items, menuLayout, menuMetadata.layout);
		}

		menuLayout.updateLayout();
	}

	/**
	 * Creates and adds decorative entities to the state.
	 * @param decorations An array of decoration metadata.
	 */
	private function buildDecorations(decorations:Array<MenuDecoration>):Void
	{
		for (decoData in decorations)
		{
			var x:Float = 0;
			var y:Float = 0;
			if (decoData.position != null)
			{
				x = decoData.position.x;
				y = decoData.position.y;
			}
			final entity = new Entity(x, y, decoData.entity);
			add(entity);
			menuEntities.set(entity.entityName, entity);
		}
	}

	/**
	 * Recursively builds an `InteractableLayout` from an array of `MenuItem`s.
	 * @param items The list of menu items to process.
	 * @param parentLayout The layout to add the created objects to.
	 * @param layoutProps The layout properties to apply to the `parentLayout`.
	 */
	private function buildLayoutFromItems(items:Array<MenuItem>, parentLayout:InteractableLayout, ?layoutProps:MenuLayout):Void
	{
		if (layoutProps != null)
		{
			if (layoutProps.direction != null)
				parentLayout.direction = layoutProps.direction;
			if (layoutProps.gap != null)
				parentLayout.gap = layoutProps.gap;
			if (layoutProps.padding != null)
				parentLayout.padding = layoutProps.padding;
			if (layoutProps.justifyContent != null)
				parentLayout.justifyContent = layoutProps.justifyContent;
			if (layoutProps.alignItems != null)
				parentLayout.alignItems = layoutProps.alignItems;
			if (layoutProps.wrap != null)
				parentLayout.wrap = layoutProps.wrap;
		}

		for (itemData in items)
		{
			var menuObject:FlxObject = null;

			if (itemData.items != null)
			{
				// This item is a sub-menu (a nested layout).
				final subLayout = new InteractableLayout();
				buildLayoutFromItems(itemData.items, subLayout, itemData.layout);
				menuObject = subLayout;
			}
			else if (itemData.entity != null)
			{
				// This item is a single, data-driven entity.
				final entity = new Entity(0, 0, itemData.entity);
				menuObject = entity;
				menuEntities.set(entity.entityName, entity);
			}

			if (menuObject != null)
			{
				// If an explicit position is set, add it directly to the state
				// and bypass the layout system for this object.
				if (itemData.position != null)
				{
					menuObject.x = itemData.position.x;
					menuObject.y = itemData.position.y;
					add(menuObject);
				}
				else // Otherwise, add it to the layout to be positioned automatically.
				{
					parentLayout.add(menuObject);
					if (itemData.alignSelf != null)
					{
						parentLayout.getLayoutData(menuObject).alignSelf = itemData.alignSelf;
					}
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (menuLayout == null || menuMetadata.inputActions == null)
			return;

		// Process data-driven input actions.
		for (inputAction in menuMetadata.inputActions)
		{
			if (Main.input.isPressed(inputAction.input))
			{
				handleMenuAction(inputAction.action);
			}
		}
	}

	/**
	 * Executes a menu action, such as navigating or accepting a selection.
	 * @param action The `MenuAction` to perform.
	 */
	public function handleMenuAction(action:MenuAction):Void
	{
		switch (action.type)
		{
			case "navigate":
				if (action.args != null && action.args.length > 0)
				{
					final amount:Int = action.args[0];
					menuLayout.changeSelection(amount);
				}

			case "accept_selection":
				// Find the selected item and trigger its `onAccept` action.
				final selectedIndex = menuLayout.selectedIndex;
				if (selectedIndex >= 0 && selectedIndex < menuMetadata.items.length)
				{
					final selectedItemData = menuMetadata.items[selectedIndex];
					if (selectedItemData.onAccept != null)
					{
						handleMenuAction(selectedItemData.onAccept);
					}
				}
		}
	}
}