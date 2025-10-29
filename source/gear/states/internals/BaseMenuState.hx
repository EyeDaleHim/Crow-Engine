package gear.states.internals;

import gear.assets.metadata.logics.LogicMetadata;
import gear.assets.metadata.menus.MenuMetadata;
import gear.entities.managers.TimerManager;
import gear.entities.managers.TweenManager;
import gear.objects.layout.InteractableLayout;
import gear.logics.LogicEvaluator;
import gear.logics.PredicateEvaluator;
import gear.logics.IEventExecutor;

/**
 * A base state for creating data-driven, interactive menus.
 * This class handles parsing menu metadata, building layouts, and processing input.
 */
class BaseMenuState extends MainState implements IEventExecutor
{
	/**
	 * The music that plays during this menu state.
	 * 
	 * The music is carried over between menu states.
	 */
	public var music:Music;

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

	/**
	 * The last beat that was processed. Used to prevent duplicate beat events.
	 */
	public var lastBeatHit:Int = -1;

	/**
	 * The last step that was processed. Used to prevent duplicate step events.
	 */
	public var lastStepHit:Int = -1;

	public var timerManager:TimerManager;
	public var tweenManager:TweenManager;

	public function new()
	{
		super();

		music = new Music();
		add(music);

		timerManager = new TimerManager();
		tweenManager = new TweenManager();
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

		music.onBeat.add(onBeat);
		music.onStep.add(onStep);

		processStoredData();

		// Initialize logic state from metadata
		if (menuMetadata.logic != null && menuMetadata.logic.initialState != null)
		{
			for (key in Reflect.fields(menuMetadata.logic.initialState))
			{
				logicState.set(key, Reflect.field(menuMetadata.logic.initialState, key));
			}
		}

		// Process asset contexts for loading and unloading
		if (menuMetadata.contexts != null)
		{
			if (menuMetadata.contexts.load != null)
			{
				for (contextName in menuMetadata.contexts.load)
				{
					Main.assets.loadContext(contextName);
				}
			}
			if (menuMetadata.contexts.unload != null)
			{
				for (contextName in menuMetadata.contexts.unload)
				{
					Main.assets.unloadContext(contextName);
				}
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

	private function processStoredData():Void
	{
		if (menuMetadata.storedData == null)
			return;

		final data:Dynamic = menuMetadata.storedData;
		final fields = Reflect.fields(data);

		for (field in fields)
		{
			final value = Reflect.field(data, field);
			logicState.set(field, value);
		}

		// Second pass for expressions
		for (field in fields)
		{
			var value = logicState.get(field);
			if (Std.isOfType(value, String))
			{
				final sValue:String = value;
				if (sValue.startsWith("random(") && sValue.endsWith(")"))
				{
					final varName = sValue.substring(7, sValue.length - 1);
					if (logicState.exists(varName))
					{
						final list:Array<Dynamic> = logicState.get(varName);
						if (list != null && list.length > 0)
						{
							logicState.set(field, list[FlxG.random.int(0, list.length - 1)]);
						}
					}
				}
			}
		}

		// Remove the original storedData to avoid confusion
		menuMetadata.storedData = null;
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
						if (elementData.screenCenter.x)
							entity.screenCenter(X);
						if (elementData.screenCenter.y)
							entity.screenCenter(Y);
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
			// Evaluate condition first to potentially skip input checks
			if (inputAction.condition != null && !PredicateEvaluator.evaluate(inputAction.condition, this.logicState))
			{
				continue;
			}

			// TODO: This input doesn't work, wtf???
			final checkType:MenuInputCheck = inputAction.check ?? JustPressed;
			var triggered:Bool = false;

			switch (checkType)
			{
				case JustPressed:
					triggered = Main.input.isJustPressed(inputAction.input);
				case JustReleased:
					triggered = Main.input.isJustPressed(inputAction.input) == false;
				case Pressed:
					triggered = Main.input.isPressed(inputAction.input);
					trace('${inputAction.input}: ${triggered}');
				case Released:
					triggered = Main.input.isPressed(inputAction.input) == false;
			}

			if (triggered)
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
			default:
				final listenerAction:ListenerActionMetadata = {type: action.type, values: action.args};
				LogicEvaluator.execute([listenerAction], this.logicState, this.menuEntities, this);
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
			// Determine the events this listener is listening for.
			var listenerEvents:Array<String> = listener.events;
			if (listenerEvents == null || listenerEvents.length == 0)
			{
				if (listener.event != null)
					listenerEvents = [listener.event];
				else
					continue; // No events defined for this listener.
			}

			// Check if the current event is one of the events this listener is interested in.
			if (!listenerEvents.contains(eventName))
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
	 * Removes all listeners that have a specific tag.
	 * @param tag The tag to look for in the listeners' `tags` array.
	 */
	public function removeListenersByTag(tag:String):Void
	{
		if (menuMetadata?.logic?.listeners == null)
			return;

		menuMetadata.logic.listeners = menuMetadata.logic.listeners.filter((listener) ->
		{
			return listener.tags == null || listener.tags.indexOf(tag) == -1;
		});
	}

	/**
	 * A general-purpose beat event handler.
	 * This should be connected to a `Music` object's `onBeat` signal.
	 * It handles beat skipping and fires the "beat" event for logic listeners.
	 * @param beat The current beat number from the music.
	 */
	public function onBeat(beat:Int):Void
	{
		if (beat <= lastBeatHit)
		{
			// Beat has reset (e.g., song looped), so reset our tracker.
			lastBeatHit = -1;
		}
		else if (beat == lastBeatHit)
		{
			// Beat was already processed, do nothing.
			return;
		}

		for (b in (lastBeatHit + 1)...(beat + 1))
			onEvent("beat", ["beat" => b]);
		lastBeatHit = beat;
	}

	/**
	 * A general-purpose step event handler.
	 * This should be connected to a `Music` object's `onStep` signal.
	 * It handles step skipping and fires the "step" event for logic listeners.
	 * @param step The current step number from the music.
	 */
	public function onStep(step:Int):Void
	{
		if (step <= lastStepHit)
		{
			// Step has reset (e.g., song looped), so reset our tracker.
			lastStepHit = -1;
		}
		else if (step == lastStepHit)
		{
			// Step was already processed, do nothing.
			return;
		}

		for (s in (lastStepHit + 1)...(step + 1))
			onEvent("step", ["step" => s]);
		lastStepHit = step;
	}

	/**
	 * Transfers attributes to the next `MainState`.
	 * Overrides the base implementation to also transfer `music`.
	 */
	override public function transferAttributeHelper(state:MainState):Void
	{
		super.transferAttributeHelper(state);
		if (Std.isOfType(state, BaseMenuState))
		{
			final castedState = cast(state, BaseMenuState);
			if (this.music != null)
				castedState.music.swapAttributes(this.music.getAttributes());
		}
	}
}
