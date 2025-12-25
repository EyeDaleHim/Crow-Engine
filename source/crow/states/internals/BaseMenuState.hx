package crow.states.internals;

import crow.assets.metadata.logics.LogicMetadata;
import crow.assets.metadata.scenes.MenuMetadata;
import crow.ds.orderedmap.OrderedStringMap;
import crow.ecs.entities.Model;
import crow.ecs.managers.TimerManager;
import crow.ecs.managers.TweenManager;
import crow.ecs.systems.BaseSystem;
import crow.ecs.systems.*;
import crow.objects.layout.InteractableLayout;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.LogicEvaluator;
import crow.logics.evaluators.PredicateEvaluator;
import crow.utils.UUID;

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
	 * The list of sounds that are currently loaded for
	 * this menu.
	 */
	public var soundInstances:Map<String, FlxSound> = [];

	/**
	 * A map of all layouts in the menu, keyed by their name.
	 */
	public var menuLayouts:Map<String, InteractableLayout> = [];

	/**
	 * A map that links a FlxObject in a layout to its original MenuItem metadata.
	 */
	public var elementMetadataMap:Map<FlxObject, MenuItem> = [];

	/**
	 * A map of all entities loaded for this menu.
	 */
	public var entities:OrderedStringMap<Entity> = new OrderedStringMap<Entity>();

	/**
	 * A list of all systems loaded for this menu, in order.
	 */
	public var systems:Array<BaseSystem> = [];

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

	private var _contextsLoaded:Bool = false;

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

		systems.push(new FieldLerpSystem());
	}

	/**
	 * Constructs the interactive menu from the loaded metadata.
	 * This is the main entry point for building the menu UI.
	 */
	public function buildMenu():Void
	{
		if (menuMetadata.asyncLoading && !_contextsLoaded)
		{
			handleContexts(menuMetadata.contexts, true, () ->
			{
				_contextsLoaded = true;
				buildMenu();
			});
			return;
		}

		if (!menuMetadata.asyncLoading)
		{
			handleContexts(menuMetadata.contexts, false);
		}

		_contextsLoaded = true;

		trace("Building menu");

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

		var rootLayoutAdded:Bool = false;
		for (element in menuMetadata.elements)
		{
			if (element.name == "_root_layout")
			{
				rootLayoutAdded = true;
				break;
			}
		}

		// --- CHANGED SECTION START ---
		var rootLayoutProps:MenuLayout = null;

		if (menuMetadata.layouts != null)
		{
			for (layout in menuMetadata.layouts)
			{
				if (layout.name == null || layout.name == "main")
				{
					rootLayoutProps = layout;
					break;
				}
			}
		}

		final rootLayout = createLayoutInstance(rootLayoutProps);

		if (!rootLayoutAdded)
			add(rootLayout);

		if (menuMetadata.asyncLoading)
		{
			trace('i do thi');
			buildElementsAsync(menuMetadata.elements, rootLayout, rootLayoutProps, rootLayoutAdded).progress((progress, length) ->
			{
				haxe.MainLoop.runInMainThread(() ->
				{
					if (parentState != null)
					{
						trace((progress / length) * 100);
						parentState.loadingScreenObject.setProgress((progress / length) * 100);
					}
				});
			}).complete(() ->
				{
					if (parentState != null)
					{
						parentState.loadingScreenObject.fadeOut(() ->
						{
							rootLayout.updateLayout();

							// Trigger the "create" event for any initial setup logic.
							onEvent("create", new LogicState());
						});
					}
				});
		}
		else
		{
			buildElements(menuMetadata.elements, rootLayout, rootLayoutProps, rootLayoutAdded);

			rootLayout.updateLayout();

			// Trigger the "create" event for any initial setup logic.
			onEvent("create", new LogicState());
		}
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
	 * @param rootLayoutInElements The `rootLayoutInElements` parameter indicates if the root layout is explicitly defined in the elements list. 
	 */
	private function buildElements(elements:Array<MenuItem>, parentLayout:InteractableLayout, ?layoutProps:MenuLayout, rootLayoutInElements:Bool = false):Void
	{
		if (layoutProps?.name != null)
		{
			menuLayouts.set(layoutProps.name, parentLayout);
		}

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
		for (rawElementData in elements)
		{
			var itemsToProcess:Array<{data:MenuItem, context:Dynamic, index:Int}> = [];

			if (rawElementData.dataSource != null)
			{
				// Fetch the list from registry
				var list:Array<Dynamic> = fetchDataSource(rawElementData.dataSource, rawElementData.dataFilter);
				var i:Int = 0;

				for (entry in list)
				{
					// Clone the metadata to create a unique instance for this entry
					var clonedItem:MenuItem = haxe.Unserializer.run(haxe.Serializer.run(rawElementData));

					clonedItem.dataSource = null;
					clonedItem.name = entry.id;

					itemsToProcess.push({data: clonedItem, context: entry, index: i});
					i++;
				}
			}
			else
			{
				itemsToProcess.push({data: rawElementData, context: null, index: -1});
			}

			for (processEntry in itemsToProcess)
			{
				var elementData = processEntry.data;
				var dataContext = processEntry.context;
				var index = processEntry.index;

				if (elementData.genericReference != null && menuMetadata.genericElements != null)
				{
					var genericItem:GenericMenuItem = null;
					for (g in menuMetadata.genericElements)
					{
						if (g.name == elementData.genericReference)
						{
							genericItem = g;
							break;
						}
					}

					if (genericItem != null)
					{
						var mergedData:MenuItem = haxe.Unserializer.run(haxe.Serializer.run(genericItem.menuItem));

						// If listenerAppends is true, merge the listeners from the specific item into the generic item's listeners.
						if (genericItem.listenerAppends == true && elementData.listeners != null && mergedData.listeners != null)
						{
							for (listener in elementData.listeners)
							{
								mergedData.listeners.push(listener);
							}
						}

						// Merge fields from the specific element into the generic one.
						// If listenerAppends is true, we skip the 'listeners' field to avoid overwriting the merge.
						// If listenerAppends is false (or null), 'listeners' will be overwritten like any other field.
						for (field in Reflect.fields(elementData))
						{
							if (genericItem.listenerAppends == true && field == "listeners")
							{
								continue;
							}

							Reflect.setField(mergedData, field, Reflect.field(elementData, field));
						}

						// Use the merged data for the rest of the processing
						elementData = mergedData;
					}
				}

				var menuObject:FlxObject = null;
				var isDecoration:Bool = (elementData.listeners == null || elementData.listeners.length == 0) && elementData.items == null;

				if (elementData.name == "_root_layout")
				{
					if (rootLayoutInElements)
					{
						rootLayoutAndData = {layout: parentLayout, data: elementData};
						if (elementData.position != null)
						{
							parentLayout.x = elementData.position.x;
							parentLayout.y = elementData.position.y;
						}
						add(parentLayout);
					}
					continue;
				}

				if (elementData.items != null)
				{
					// This item is a sub-menu (a nested layout).
					final subLayout = createLayoutInstance(elementData.layout);
					buildElements(elementData.items, subLayout, elementData.layout);
					menuObject = subLayout;
				}
				else if (elementData.entity != null)
				{
					var initialState:Dynamic = {};

					if (dataContext != null)
					{
						// Inject data properties (id, displayName, etc.) into the Entity's logic state.
						if (Reflect.hasField(dataContext, "id"))
							Reflect.setField(initialState, "id", Reflect.field(dataContext, "id"));

						if (Reflect.hasField(dataContext, "displayName"))
							Reflect.setField(initialState, "displayName", Std.string(Reflect.field(dataContext, "displayName")));

						// Inject metaInfo if available
						if (Reflect.hasField(dataContext, "metaInfo") && Reflect.field(dataContext, "metaInfo") != null)
						{
							var meta:Dynamic = Reflect.field(dataContext, "metaInfo");
							for (f in Reflect.fields(meta))
							{
								Reflect.setField(initialState, f, Reflect.field(meta, f));
							}
						}
					}

					if (index != -1)
					{
						Reflect.setField(initialState, "index", index);
					}

					// This item is a single, data-driven entity.
					final entity = new Entity(0, 0, elementData.entity, elementData.overrideData, initialState);
					menuObject = entity.getModel();

					if (elementData.name == null)
					{
						elementData.name = entity.entityName;
					}
					entities.set(elementData.name, entity);

					if (dataContext != null)
					{
						// Force an update on the entity to refresh Text/Sprites with new variables
						// We might need a specific "refresh" method or trigger a specific event
						// We use a local event execution for this entity
						var singleEntityMap = new OrderedStringMap<Entity>();
						singleEntityMap.set(entity.entityName, entity);

						executeLogic( // Create a dummy action to update text or run init logic
							[
								{type: "state_change", values: {state: {changeType: "SET", stateKey: "dummy", value: 0}}}
							], logicState, null, singleEntityMap, // OrderedMap helper
							this);

						// If the entity has listeners for "create", trigger them now with the new data
						onItemEvent(elementData, "create", entity, entity.logicState);
					}
				}
				else if (elementData.name == null)
				{
					elementData.name = UUID.generateV4();
				}

				if (menuObject != null)
				{
					var menuObjectAsModel:Model = cast(menuObject, Model);
					if (elementData.position != null || elementData.screenCenter != null || isDecoration)
					{
						if (elementData.position != null)
						{
							menuObject.x = elementData.position.x;
							menuObject.y = elementData.position.y;
						}
						if (elementData.screenCenter != null && Std.isOfType(menuObject, Model))
						{
							final model:Model = cast menuObject;
							if (elementData.screenCenter.x)
								model.screenCenter(X);
							if (elementData.screenCenter.y)
								model.screenCenter(Y);
						}
						add(menuObjectAsModel.entity);
					}
					else
					{
						parentLayout.add(menuObjectAsModel.entity);
						elementMetadataMap.set(menuObjectAsModel.entity, elementData);
						if (elementData.alignSelf != null)
						{
							parentLayout.getLayoutData(menuObjectAsModel.entity).alignSelf = elementData.alignSelf;
						}
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

	/**
	 * Recursively builds an `InteractableLayout` from an array of `MenuItem`s, asynchronously.
	 * @param elements 
	 * @param parentLayout 
	 * @param layoutProps 
	 * @param rootLayoutInElements 
	 * @return This ThreadSignals instance.
	 */
	private function buildElementsAsync(elements:Array<MenuItem>, parentLayout:InteractableLayout, ?layoutProps:MenuLayout,
			rootLayoutInElements:Bool = false):ThreadSignals
	{
		if (layoutProps?.name != null)
		{
			menuLayouts.set(layoutProps.name, parentLayout);
		}

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

		function countTasks(?elementItems:Array<MenuItem>):Int
		{
			elementItems ??= elements;

			var totalTasks = 0;
			for (rawElementData in elementItems)
			{
				if (rawElementData.dataSource != null)
				{
					// Each item in a data source will generate an entity
					var list:Array<Dynamic> = fetchDataSource(rawElementData.dataSource, rawElementData.dataFilter);
					totalTasks += list.length;
				}
				else if (rawElementData.entity != null)
				{
					// A single entity
					totalTasks++;
				}
				else if (rawElementData.items != null)
				{
					// Nested layout, recursively count
					totalTasks += countTasks(rawElementData.items);
				}
			}
			return totalTasks;
		}

		final totalTasks = countTasks();
		if (totalTasks == 0)
		{
			Main.entityBuilderThread.resetProgress(1);
			Main.entityBuilderThread.incrementProgress();
			return Main.entityBuilderThread.signals;
		}

		Main.entityBuilderThread.resetProgress(totalTasks);

		function scheduleElements(items:Array<MenuItem>, layout:InteractableLayout):Void
		{
			if (items == null || items.length == 0)
				return;

			for (rawElementData in items)
			{
				var itemsToProcess:Array<{data:MenuItem, context:Dynamic, index:Int}> = [];

				if (rawElementData.dataSource != null)
				{
					var list:Array<Dynamic> = fetchDataSource(rawElementData.dataSource, rawElementData.dataFilter);
					var i:Int = 0;

					for (entry in list)
					{
						var clonedItem:MenuItem = haxe.Unserializer.run(haxe.Serializer.run(rawElementData));
						clonedItem.dataSource = null;
						clonedItem.name = entry.id;
						itemsToProcess.push({data: clonedItem, context: entry, index: i});
						i++;
					}
				}
				else
				{
					itemsToProcess.push({data: rawElementData, context: null, index: -1});
				}

				for (processEntry in itemsToProcess)
				{
					final elementData = processEntry.data;
					final dataContext = processEntry.context;
					final index = processEntry.index;

					if (elementData.name == "_root_layout")
					{
						if (rootLayoutInElements)
						{
							if (elementData.position != null)
							{
								layout.x = elementData.position.x;
								layout.y = elementData.position.y;
							}
							add(layout);

							if (elementData.screenCenter != null)
							{
								layout.updateLayout();
								if (elementData.screenCenter.x)
									layout.screenCenter(X);
								if (elementData.screenCenter.y)
									layout.screenCenter(Y);
							}
						}
						continue;
					}

					if (elementData.items != null)
					{
						final subLayout = createLayoutInstance(elementData.layout);
						layout.add(subLayout);
						scheduleElements(elementData.items, subLayout);
						continue;
					}

					Main.entityBuilderThread.add(() ->
					{
						try
						{
							var processedData = elementData;

							if (processedData.genericReference != null && menuMetadata.genericElements != null)
							{
								var genericItem:GenericMenuItem = null;
								for (g in menuMetadata.genericElements)
								{
									if (g.name == processedData.genericReference)
									{
										genericItem = g;
										break;
									}
								}

								if (genericItem != null)
								{
									var mergedData:MenuItem = haxe.Unserializer.run(haxe.Serializer.run(genericItem.menuItem));
									if (genericItem.listenerAppends == true && processedData.listeners != null && mergedData.listeners != null)
									{
										for (listener in processedData.listeners)
											mergedData.listeners.push(listener);
									}

									for (field in Reflect.fields(processedData))
									{
										if (genericItem.listenerAppends == true && field == "listeners")
											continue;
										Reflect.setField(mergedData, field, Reflect.field(processedData, field));
									}
									processedData = mergedData;
								}
							}

							var menuObject:FlxObject = null;
							var entity:Entity = null;
							var isDecoration:Bool = (processedData.listeners == null || processedData.listeners.length == 0)
								&& processedData.items == null;

							if (processedData.entity != null)
							{
								var initialState:Dynamic = {};
								if (dataContext != null)
								{
									if (Reflect.hasField(dataContext, "id"))
										Reflect.setField(initialState, "id", Reflect.field(dataContext, "id"));
									if (Reflect.hasField(dataContext, "displayName"))
										Reflect.setField(initialState, "displayName", Std.string(Reflect.field(dataContext, "displayName")));
									if (Reflect.hasField(dataContext, "metaInfo") && Reflect.field(dataContext, "metaInfo") != null)
									{
										var meta:Dynamic = Reflect.field(dataContext, "metaInfo");
										for (f in Reflect.fields(meta))
											Reflect.setField(initialState, f, Reflect.field(meta, f));
									}
								}

								if (index != -1)
									Reflect.setField(initialState, "index", index);

								entity = new Entity(0, 0, processedData.entity, processedData.overrideData, initialState);
								menuObject = entity.getModel();

								if (processedData.name == null)
									processedData.name = entity.entityName;
							}
							else if (processedData.name == null)
							{
								processedData.name = UUID.generateV4();
							}

							if (entity != null)
							{
								entities.set(processedData.name, entity);
								if (dataContext != null)
								{
									var singleEntityMap = new OrderedStringMap<Entity>();
									singleEntityMap.set(entity.entityName, entity);
									executeLogic([
										{type: "state_change", values: {state: {changeType: "SET", stateKey: "dummy", value: 0}}}
									], logicState, null, singleEntityMap, this);
									onItemEvent(processedData, "create", entity, entity.logicState);
								}
							}

							if (menuObject != null)
							{
								haxe.MainLoop.runInMainThread(() ->
								{
									var menuObjectAsModel:Model = cast(menuObject, Model);
									if (processedData.position != null || processedData.screenCenter != null || isDecoration)
									{
										if (processedData.position != null)
										{
											menuObject.x = processedData.position.x;
											menuObject.y = processedData.position.y;
										}
										if (processedData.screenCenter != null)
										{
											final model:Model = cast menuObject;
											if (processedData.screenCenter.x)
												model.screenCenter(X);
											if (processedData.screenCenter.y)
												model.screenCenter(Y);
										}
										add(menuObjectAsModel.entity);
									}
									else
									{
										layout.add(menuObjectAsModel.entity);
										elementMetadataMap.set(menuObjectAsModel.entity, processedData);
										if (processedData.alignSelf != null)
										{
											layout.getLayoutData(menuObjectAsModel.entity).alignSelf = processedData.alignSelf;
										}
									}
									Main.entityBuilderThread.incrementProgress();
								});
							}
						}
						catch (e:Dynamic)
						{
							trace('Error building entity async: $e');
							haxe.MainLoop.runInMainThread(() -> Main.entityBuilderThread.incrementProgress());
						}
					});
				}
			}
		}

		scheduleElements(elements, parentLayout);

		return Main.entityBuilderThread.signals;
	}

	override function update(elapsed:Float)
	{
		for (system in systems)
			system.preUpdate(elapsed);

		super.update(elapsed);

		onEvent("update");

		if (menuMetadata?.inputActions == null)
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
				case Repeated:
					final adv = inputAction.advanced;
					if (adv != null)
					{
						var isPaused = false;
						if (adv.pauseOnOthers != null)
						{
							for (otherInput in adv.pauseOnOthers)
							{
								if (Main.input.isPressed(otherInput))
								{
									isPaused = true;
									break;
								}
							}
						}

						if (!isPaused)
							triggered = Main.input.isRepeated(inputAction.input, adv.repeatStart, adv.repeatRate);
					}
					else
					{
						triggered = Main.input.isRepeated(inputAction.input);
					}
			}

			if (triggered)
			{
				if (inputAction.actions != null)
				{
					for (action in inputAction.actions)
						handleMenuAction(action, null, null, new LogicState());
				}
			}
		}

		for (entity in entities)
		{
			for (system in systems)
			{
				system.processEntity(entity, elapsed);
			}
		}

		for (system in systems)
			system.postUpdate(elapsed);

		for (system in systems)
		{
			@:privateAccess
			for (weak in system._weakComponents)
			{
				if (weak.entity != null)
				{
					weak.entity.removeComponent(weak);
				}
				weak.destroy();
			}

			@:privateAccess
			system._weakComponents.splice(0, system._weakComponents.length);
		}
	}

	/**
	 * Triggers an event specifically on a MenuItem.
	 * This filters the item's listener list for the specific event name.
	 */
	public function onItemEvent(item:MenuItem, eventName:String, ?entity:Entity, ?localState:LogicState):Void
	{
		if (item.listeners == null)
			return;

		// Reuse the main onEvent logic, but scope it to this item's listeners
		// We create a temporary LogicMetadata structure to pass to a helper or duplicate the logic slightly.
		// Here is the direct implementation for clarity:

		localState ??= new LogicState();

		for (listener in item.listeners)
		{
			var listenerEvents = listener.events ?? (listener.event != null ? [listener.event] : []);

			if (!listenerEvents.contains(eventName))
				continue;

			// Evaluate condition
			if (!PredicateEvaluator.evaluate(listener.condition, this.logicState, localState))
				continue;

			// Prepare entity map for the action (usually the item itself)
			var targetMap:OrderedStringMap<Entity> = null;
			if (entity != null)
			{
				targetMap = new OrderedStringMap<Entity>();
				targetMap.set(entity.entityName, entity);
			}
			else
			{
				trace("Entity null");
			}

			// Execute actions
			if (listener.actions != null)
			{
				executeLogic(listener.actions, this.logicState, localState, targetMap ?? this.entities, this);
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

		var map:OrderedStringMap<Entity> = new OrderedStringMap<Entity>();
		if (entity != null)
			map.set(entity.entityName, entity);
		executeLogic([action], this.logicState, localState, map, this);
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
				executeLogic(listener.actions, this.logicState, localState, this.entities, this);

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
	 * A wrapper which simply calls `LogicEvaluator.execute` with the provided parameters. 
	 * This method exists to allow overriding.
	 * @param actions 
	 * @param executorState 
	 * @param localState 
	 * @param entities 
	 * @param executor 
	 */
	public function executeLogic(actions:Array<ListenerActionMetadata>, executorState:LogicState, ?localState:LogicState, ?entities:OrderedStringMap<Entity>,
			?executor:IEventExecutor)
	{
		LogicEvaluator.execute(actions, executorState, localState, entities, executor);
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

	private function createLayoutInstance(props:MenuLayout):InteractableLayout
	{
		var layout:InteractableLayout;

		if (props == null)
		{
			return (layout = new InteractableLayout());
		}

		switch (props.type)
		{
			case DYNAMIC:
				{
					var dyn = new crow.objects.layout.DynamicListLayout();
					if (props.lerpSpeed != null)
						dyn.lerpSpeed = props.lerpSpeed;
					if (props.xOffset != null)
						dyn.xOffset = props.xOffset;
					if (props.centerOnSelection != null)
						dyn.centerOnSelection = props.centerOnSelection;
					if (props.deselectedAlpha != null)
						dyn.deselectedAlpha = props.deselectedAlpha;
					layout = dyn;
				}
			default:
				{
					layout = new InteractableLayout();
				}
		}

		if (props.position != null)
		{
			layout.x = props.position.x ?? layout.x;
			layout.y = props.position.y ?? layout.y;
		}

		return layout;
	}

	/**
	 * Helper to retrieve data lists from LevelRegistry
	 */
	private function fetchDataSource(source:MenuDataSource, filter:String):Array<Dynamic>
	{
		var results:Array<Dynamic> = [];

		switch (source)
		{
			case GROUPS:
				// Return objects containing {id, displayName, metaInfo}
				for (gid in Main.levels.sortedGroupIDs)
				{
					var g = Main.levels.getGroup(gid);
					if (g != null && g.isVisible())
					{
						results.push({
							id: g.id,
							displayName: g.title,
							metaInfo: g.data.metaInfo
						});
					}
				}
			case LEVELS:
				// Expects filter to be a Group ID
				var g = Main.levels.getGroup(filter);
				if (g != null)
				{
					for (lvl in g.levels)
					{
						// Check level specific visibility if you have it
						results.push({
							id: lvl.id,
							displayName: lvl.title,
							metaInfo: lvl.data.metaInfo
						});
					}
				}
			case PLAYLIST:
				// Implementation for playlists
		}

		return results;
	}
}
