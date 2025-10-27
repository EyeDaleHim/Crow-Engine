package gear.states.internals;

import gear.assets.metadata.logics.LogicMetadata;
import gear.assets.metadata.menus.MenuMetadata;
import gear.objects.layout.InteractableLayout;
import gear.logics.LogicEvaluator;
import gear.logics.PredicateEvaluator;

/**
 * A base state for creating data-driven, interactive menus.
 * This class handles parsing menu metadata, building layouts, and processing input.
 */
class BaseMenuState extends MainState
{
	/**
	 * The music that plays during this menu state.
	 * 
	 * The music is carried over between menu states.
	 */
	public var menuMusic:Music;

	/**
	 * The root layout container for the entire menu.
	 */
	public var menuLayout:InteractableLayout;

	/**
	 * A map of all entities loaded for this menu.
	 */
	public var menuEntities:Map<String, Entity> = [];

	/**
	 * The metadata that defines the structure and behavior of this menu.
	 */
	public var menuMetadata:MenuMetadata;

	/**
	 * The internal state for the menu's logic, which can be modified by listeners.
	 */
	public var logicState:Map<String, Dynamic> = [];

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

		// Initialize logic state from metadata
		if (menuMetadata.logic != null && menuMetadata.logic.initialState != null)
		{
			for (key in Reflect.fields(menuMetadata.logic.initialState))
			{
				logicState.set(key, Reflect.field(menuMetadata.logic.initialState, key));
			}
		}

		menuLayout = new InteractableLayout();
		add(menuLayout);

		if (menuMetadata.elements != null)
		{
			buildElements(menuMetadata.elements, menuLayout, menuMetadata.layout);
		}

		menuLayout.updateLayout();

		// Trigger the "create" event for any initial setup logic.
		onEvent("create");
	}

	/**
	 * Recursively builds an `InteractableLayout` from an array of `MenuItem`s.
	 * @param items The list of menu items to process.
	 * @param parentLayout The layout to add the created objects to.
	 * @param layoutProps The layout properties to apply to the `parentLayout`.
	 */
	private function buildElements(elements:Array<MenuItem>, parentLayout:InteractableLayout, ?layoutProps:MenuLayout):Void
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

		for (elementData in elements)
		{
			var menuObject:FlxObject = null;
			var isDecoration:Bool = elementData.onAccept == null && elementData.items == null;

			if (elementData.items != null)
			{
				// This item is a sub-menu (a nested layout).
				final subLayout = new InteractableLayout();
				buildElements(elementData.items, subLayout, elementData.layout);
				menuObject = subLayout;
			}
			else if (elementData.entity != null)
			{
				// This item is a single, data-driven entity.
				final entity = new Entity(0, 0, elementData.entity);
				menuObject = entity;
				menuEntities.set(entity.entityName, entity);
			}

			if (menuObject != null)
			{
				if (elementData.position != null || elementData.screenCenter != null || isDecoration)
				{
					if (elementData.position != null)
					{
						menuObject.x = elementData.position.x;
						menuObject.y = elementData.position.y;
					}
					if (elementData.screenCenter != null && Std.isOfType(menuObject, Entity))
					{
						final entity:Entity = cast menuObject;
						if (elementData.screenCenter.x) entity.screenCenter(X);
						if (elementData.screenCenter.y) entity.screenCenter(Y);
					}
					add(menuObject);
				}
				else
				{
					parentLayout.add(menuObject);
					if (elementData.alignSelf != null)
					{
						parentLayout.getLayoutData(menuObject).alignSelf = elementData.alignSelf;
					}
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		onEvent("update");

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
				if (menuMetadata.elements != null && selectedIndex >= 0 && selectedIndex < menuMetadata.elements.length)
				{
					final selectedElement = menuMetadata.elements[selectedIndex];
					if (selectedElement.onAccept != null)
					{
						handleMenuAction(selectedElement.onAccept);
					}
				}
		}
	}

	/**
	 * Triggers actions for any listeners associated with the given event.
	 * This is the core of the data-driven logic system for menus.
	 * @param eventName The name of the event to trigger (e.g., "beat", "update").
	 * @param args A map of additional data to be temporarily available in the state for predicate evaluation.
	 */
	public function onEvent(eventName:String, ?args:Map<String, Dynamic>):Void
	{
		if (menuMetadata?.logic?.listeners == null)
			return;

		var listenersToRemove:Array<ListenerMetadata> = null;

		for (listener in menuMetadata.logic.listeners)
		{
			if (listener.event != eventName)
				continue;

			// If args are provided, temporarily add them to the state for evaluation.
			if (args != null)
			{
				for (key in args.keys())
					logicState.set(key, args.get(key));
			}

			// Evaluate the condition.
			final conditionMet = PredicateEvaluator.evaluate(listener.condition, this.logicState);

			// Clean up the temporary state variables.
			if (args != null)
			{
				for (key in args.keys())
					logicState.remove(key);
			}

			if (!conditionMet)
				continue;

			// All conditions passed, execute actions.
			if (listener.actions != null)
				LogicEvaluator.execute(listener.actions, this.logicState, this.menuEntities, this);

			// If the listener is weak, mark it for removal.
			if (listener.weak)
			{
				if (listenersToRemove == null)
					listenersToRemove = [];
				listenersToRemove.push(listener);
			}
		}

		// Remove any weak listeners that were triggered.
		if (listenersToRemove != null)
		{
			for (listener in listenersToRemove)
				menuMetadata.logic.listeners.remove(listener);
		}
	}

	/**
	 * Transfers attributes to the next `MainState`.
	 * Overrides the base implementation to also transfer `menuMusic`.
	 */
	override public function transferAttributeHelper(state:MainState):Void
	{
		super.transferAttributeHelper(state);
		if (Std.isOfType(state, BaseMenuState))
			cast(state, BaseMenuState).menuMusic = this.menuMusic;
	}
}
