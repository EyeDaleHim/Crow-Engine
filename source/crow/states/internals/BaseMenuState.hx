package crow.states.internals;

import crow.assets.metadata.logics.LogicMetadata;
import crow.assets.metadata.menus.MenuMetadata;
import crow.entities.managers.TimerManager;
import crow.entities.managers.TweenManager;
import crow.objects.layout.InteractableLayout;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.LogicEvaluator;
import crow.logics.evaluators.PredicateEvaluator;

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
	public var entities:Map<String, Entity> = [];

	/**
	 * The metadata that defines the structure and behavior of this menu.
	 */
	public var menuMetadata:MenuMetadata;

	/**
	 * The internal state for the menu's logic, which can be modified by listeners.
	 */
	public var logicState:LogicState = new LogicState();

	/**
	 * The last beat that was processed. Used to prevent duplicate beat events.
	 */
	public var lastBeatHit:Int = -1;

	/**
	 * The last step that was processed. Used to prevent duplicate step events.
	 */
	public var lastStepHit:Int = -1;

	/**
	 * The available scenes this state is allowed to switch to.
	 */
	public var nextScenes:Array<String>;

	public var timerManager:TimerManager;
	public var tweenManager:TweenManager;

	public function new()
	{
		super();

		music = new Music();
		add(music);

		timerManager = new TimerManager();
		tweenManager = new TweenManager();

		openCallback = () ->
		{
			if (menuMetadata?.transitions?.skipIn != true)
			{
				transitionIn(onEvent.bind("transitionInFinished"));
			}
			else
			{
				onEvent("transitionInFinished");
			}
		};
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
			transitionIn(onEvent.bind("transitionInFinished"));
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
			if (menuMetadata.contexts.unload != null)
			{
				for (contextName in menuMetadata.contexts.unload)
				{
					Main.assets.unloadContext(contextName);
				}
			}
			if (menuMetadata.contexts.load != null)
			{
				for (contextName in menuMetadata.contexts.load)
				{
					Main.assets.loadContext(contextName);
				}
			}
		}

		var rootLayoutAdded:Bool = false;
		for (element in menuMetadata.elements)
		{
			if (element.name == "_root_layout")
			{
				rootLayoutAdded = true;
				break;
			}
		}

		menuLayout = new InteractableLayout();
		if (!rootLayoutAdded)
			add(menuLayout);

		buildElements(menuMetadata.elements, menuLayout, menuMetadata.layout, rootLayoutAdded);

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
	private function buildElements(elements:Array<MenuItem>, parentLayout:InteractableLayout, ?layoutProps:MenuLayout, rootLayoutInElements:Bool = false):Void
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
			if (layoutProps.gapBehavior != null)
				parentLayout.gapBehavior = layoutProps.gapBehavior;
			if (layoutProps.autoSize != null)
				parentLayout.autoSize = layoutProps.autoSize;
			if (layoutProps.selectionMode != null)
				parentLayout.selectionMode = layoutProps.selectionMode;

			if (layoutProps.onDeselect != null)
			{
				parentLayout.onDeselect.add((deselected) ->
				{
					final selectedIndex = parentLayout.selectedIndex;
					final selectedItem = menuMetadata.elements[selectedIndex];
					final selectedEntity = entities.get(selectedItem.name);
					handleMenuAction(layoutProps.onDeselect, selectedItem, selectedEntity);
				});
			}

			if (layoutProps.onSelect != null)
			{
				parentLayout.onSelect.add((selected) ->
				{
					final selectedIndex = parentLayout.selectedIndex;
					final selectedItem = menuMetadata.elements[selectedIndex];
					final selectedEntity = entities.get(selectedItem.name);
					handleMenuAction(layoutProps.onSelect, selectedItem, selectedEntity);
				});
			}

			if (layoutProps.onIndex != null)
			{
				parentLayout.onIndex.add((oldIndex, newIndex) ->
				{
					final selectedItem = menuMetadata.elements[newIndex];
					final selectedEntity = entities.get(selectedItem.name);

					final localState = new LogicState();
					localState.set("oldIndex", oldIndex);
					localState.set("newIndex", newIndex);

					handleMenuAction(layoutProps.onIndex, selectedItem, selectedEntity, localState);
				});
			}
		}

		if (elements == null || elements.length == 0)
			return;

		var rootLayoutAndData:{layout:InteractableLayout, data:Dynamic} = null;
		for (elementData in elements)
		{
			var menuObject:FlxObject = null;
			var isDecoration:Bool = elementData.onAccept == null && elementData.items == null;

			if (elementData.name == "_root_layout")
			{
				if (rootLayoutInElements)
				{
					rootLayoutAndData = {layout: parentLayout, data: elementData};
					if (elementData.position != null)
					{
						if (elementData.position != null)
						{
							parentLayout.x = elementData.position.x;
							parentLayout.y = elementData.position.y;
						}
					}
					add(parentLayout);
				}
				continue;
			}

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
				final entity = new Entity(0, 0, elementData.entity, elementData.overrideData);
				menuObject = entity;
				entities.set(entity.entityName, entity);
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

		if (rootLayoutAndData != null)
		{
			if (rootLayoutAndData.data.screenCenter != null)
			{
				rootLayoutAndData.layout.updateLayout();
				if (rootLayoutAndData.data.screenCenter.x)
					rootLayoutAndData.layout.screenCenter(X);
				if (rootLayoutAndData.data.screenCenter.y)
					rootLayoutAndData.layout.screenCenter(Y);
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
				case Released:
					triggered = Main.input.isPressed(inputAction.input) == false;
			}

			if (triggered)
			{
				if (inputAction.actions != null)
				{
					for (action in inputAction.actions)
						handleMenuAction(action, null, null, null);
				}
			}
		}
	}

	/**
	 * Executes a menu action, such as navigating or accepting a selection.
	 * @param action The `ListenerActionMetadata` to perform.
	 * @param menuItem The `MenuItem` associated with this action.
	 * @param entity The `Entity` that triggered the action (if any). 	 
	 * @param localState Optional local state for the action.
	 */
	public function handleMenuAction(action:ListenerActionMetadata, ?menuItem:MenuItem, ?entity:Entity, ?localState:LogicState):Void
	{
		localState ??= new LogicState();

		switch (action.type)
		{
			case "navigate":
				if (action.values != null)
				{
					final formerIndex = menuLayout.selectedIndex;
					final formerItem = menuMetadata.elements[formerIndex];
					final formerEntity = entities.get(formerItem.name);

					final amount:Int = action.values.direction ?? 0;
					menuLayout.changeSelection(amount);

					if (formerItem?.onDeselect != null)
					{
						localState.set("index", formerIndex);
						handleMenuAction(formerItem.onDeselect, formerItem, formerEntity, localState);
					}

					final selectedIndex = menuLayout.selectedIndex;
					final selectedItem = menuMetadata.elements[selectedIndex];
					final selectedEntity = entities.get(selectedItem.name);

					if (selectedItem.onSelect != null)
					{
						localState.set("index", selectedIndex);
						handleMenuAction(selectedItem.onSelect, selectedItem, selectedEntity, localState);
					}

					if (localState != null)
					{
						localState.clear();
					}

					if (selectedItem.onIndex != null)
					{
						localState.set("oldIndex", formerIndex);
						localState.set("newIndex", selectedIndex);

						handleMenuAction(selectedItem.onIndex, selectedItem, selectedEntity, localState);
					}
				}

			case "accept_selection":
				// Find the selected item and trigger its `onAccept` action.
				final selectedIndex = menuLayout.selectedIndex;
				if (menuMetadata.elements != null && selectedIndex >= 0 && selectedIndex < menuMetadata.elements.length)
				{
					final selectedItem = menuMetadata.elements[selectedIndex];
					if (selectedItem.onAccept != null)
					{
						final selectedEntity = entities.get(selectedItem.name);
						handleMenuAction(selectedItem.onAccept, selectedItem, selectedEntity, logicState);
					}
				}
			case "return_to_previous_scene":
				final onFinish = () ->
				{
					if (_parentState != null)
					{
						var state = cast(_parentState, BaseMenuState);
						state.onReturn();
						state.closeSubState();
					}
				};

				if (menuMetadata?.transitions?.skipOut == true)
				{
					onFinish();
				}
				else
				{
					transitionOut(onFinish);
				}
			default:
				final listenerAction:ListenerActionMetadata = {type: action.type, values: action.values};
				var map:Map<String, Entity> = [];
				if (entity != null)
					map.set(entity.entityName, entity);

				LogicEvaluator.execute([listenerAction], this.logicState, localState, map, this);
		}
	}

	/**
	 * Triggers actions for any listeners associated with the given event.
	 * This is the core of the data-driven logic system for menus.
	 * @param eventName The name of the event to trigger (e.g., "beat", "update").
	 * @param localState The local scope for this event.
	 */
	public function onEvent(eventName:String, ?localState:LogicState):Void
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

			// Evaluate the condition.
			final conditionMet = PredicateEvaluator.evaluate(listener.condition, this.logicState, localState);

			if (!conditionMet)
				continue;

			// All conditions passed, execute actions.
			if (listener.actions != null)
				LogicEvaluator.execute(listener.actions, this.logicState, localState, this.entities, this);

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
	 * The scene to switch to. Use `super.switchScene()` to determine if the scene is valid.
	 * @param sceneName The name of the scene to switch to.
	 * @return Bool The result of the switch attempt.
	 */
	public function switchScene(sceneName:String):Bool
	{
		if (nextScenes == null)
		{
			trace('ERROR: nextScenes is not defined. Cannot switch scene to $sceneName');
			return false;
		}

		if (!nextScenes.contains(sceneName))
		{
			trace('ERROR: Scene "$sceneName" is not in the list of allowed nextScenes.');
			return false;
		}

		final nextState = createScene(sceneName);

		if (nextState == null)
		{
			trace('ERROR: Could not create scene: $sceneName. The createScene() method may not be implemented for this state or scene name.');
			return false;
		}

		return openNextScene(nextState);
	}

	/**
	 * Creates and returns a new `BaseMenuState` instance based on the provided scene name.
	 * This method is intended to be overridden by subclasses to define their specific scene transitions.
	 *
	 * @param sceneName The identifier for the scene to create.
	 * @return A new `BaseMenuState` instance, or `null` if the scene name is not recognized.
	 */
	public function createScene(sceneName:String):BaseMenuState
	{
		// To be implemented by subclasses.
		return null;
	}

	public function openNextScene(nextState:BaseMenuState):Bool
	{
		if (nextState == null)
			return false;

		final onFinish = () ->
		{
			transferAttributeHelper(nextState);
			openSubState(nextState);
		};

		if (menuMetadata?.transitions?.skipOut == true)
		{
			onFinish();
		}
		else
		{
			transitionOut(onFinish);
		}
		return true;
	}

	/**
	 * Called when a sub-state is closed and returns to this state.
	 * Dispatches a "return" event that can be caught by logic listeners.
	 */
	public function onReturn():Void
	{
		if (menuMetadata?.transitions?.skipReturn != true)
		{
			transitionIn(onEvent.bind("transitionInFinished"));
		}
		else
		{
			onEvent("transitionInFinished");
		}
		onEvent("return");
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

		logicState.set("beat", beat);

		for (b in (lastBeatHit + 1)...(beat + 1))
		{
			// Calculate the time this beat should have occurred
			final beatTime = music.beatToMs(b);
			// Calculate the difference between when it should have happened and the current music time
			final elapsed = music.position - beatTime;

			var localState = new LogicState();
			localState.set("beat", b);
			localState.set("catchupMs", elapsed);
			localState.set("compensate", b == beat && Math.abs(lastBeatHit - beat) > 1);
			onEvent("beat", localState);
		}

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

		logicState.set("step", step);

		for (s in (lastStepHit + 1)...(step + 1))
		{
			final stepTime = music.stepToMs(s);
			final elapsed = music.position - stepTime;

			var localState = new LogicState();
			localState.set("step", s);
			localState.set("catchupMs", elapsed);
			localState.set("compensate", s == step && Math.abs(lastStepHit - step) > 1);
			onEvent("step", localState);
		}
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
