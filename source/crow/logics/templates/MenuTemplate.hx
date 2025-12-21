package crow.logics.templates;

import crow.ecs.components.data.LoadLevelComponent;
import crow.ecs.entities.Entity;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.Template;
import crow.states.internals.BaseMenuState;

/**
 * A template for menu-related actions.
 */
class MenuTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			"navigate" => ExecutableAction.createAction((ctx) ->
			{
				final menuState = cast(ctx.executor, BaseMenuState);
				final layoutName:String = ctx.values.layout;

				final targetLayout = menuState.menuLayouts.get(layoutName);
				if (targetLayout == null)
				{
					trace('ERROR: Could not find layout with name: $layoutName');
					return;
				}

				final formerObject = targetLayout.selectedObject;
				final formerItem = menuState.elementMetadataMap.get(formerObject);

				final formerEntity = menuState.entities.get(formerItem.name);

				final amount:Int = ctx.values.direction ?? 0;
				targetLayout.changeSelection(amount);

				final localState = ctx.localState ?? new LogicState();

				final deselectState = ctx.localState ?? new LogicState();
				deselectState.set("index", targetLayout.members.indexOf(formerObject));

				// REPLACED: menuState.handleMenuAction(formerItem.onDeselect...
				menuState.onItemEvent(formerItem, "deselect", formerEntity, deselectState);

				final selectedObject = targetLayout.selectedObject;
				final selectedItem = menuState.elementMetadataMap.get(selectedObject);

				final selectedEntity = menuState.entities.get(selectedItem.name);

				final selectState = ctx.localState ?? new LogicState();
				selectState.set("index", targetLayout.selectedIndex);

				// REPLACED: menuState.handleMenuAction(selectedItem.onSelect...
				menuState.onItemEvent(selectedItem, "select", selectedEntity, selectState);

				if (ctx.localState != null)
				{
					ctx.localState.clear();
				}

				localState.set("oldIndex", targetLayout.members.indexOf(formerObject));
				localState.set("newIndex", targetLayout.selectedIndex);

				menuState.onItemEvent(selectedItem, "index", selectedEntity, localState);
			},
				[{name: "layout", type: "String"}, {name: "direction", type: "Int"}], {wantsExecutor: true}),
			"accept_selection" => ExecutableAction.createAction((ctx) ->
			{
				final menuState = cast(ctx.executor, BaseMenuState);
				final layoutName:String = ctx.values?.layout;

				final targetLayout = menuState.menuLayouts.get(layoutName);
				if (targetLayout == null)
				{
					trace('ERROR: Could not find layout with name: $layoutName');
					return;
				}

				final selectedObject = targetLayout.selectedObject;
				if (selectedObject != null)
				{
					final selectedItem = menuState.elementMetadataMap.get(selectedObject);
					if (selectedItem != null)
					{
						final selectedEntity = menuState.entities.get(selectedItem.name);

						menuState.onItemEvent(selectedItem, "accept", selectedEntity, menuState.logicState);
					}
				}
			},
				[{name: "layout", type: "String"}], {wantsExecutor: true}),
			"return_to_previous_scene" => ExecutableAction.createAction((ctx) ->
			{
				final menuState = cast(ctx.executor, BaseMenuState);

				final onFinish = () ->
				{
					@:privateAccess
					if (menuState._parentState != null)
					{
						var state = cast(menuState._parentState, BaseMenuState);
						state.onReturn();
						state.closeSubState();
					}
				};

				if (menuState.menuMetadata?.transitions?.skipOut == true)
				{
					onFinish();
				}
				else
				{
					menuState.transitionOut(onFinish);
				}
			}, [], {wantsExecutor: true}),
			"load_level" => ExecutableAction.createAction((ctx) ->
			{
				final menuState = cast(ctx.executor, BaseMenuState);
				final levelName:String = ctx.values.level;

				if (ctx.targetedEntities == null || ctx.targetedEntities.length == 0)
				{
					trace('ERROR: No entity targeted for level loading.');
					return;
				}

				final entity = ctx.targetedEntities[0];
				final levelComponent = cast(entity.getComponentByType(LoadLevelComponent), LoadLevelComponent);

				if (levelComponent == null)
				{
					trace('ERROR: Targeted entity does not have a LoadLevelComponent.');
					return;
				}

				menuState.loadGame(levelComponent.gameStem);
			}, [], {wantsExecutor: true, wantsTargetedEntities: true}),
		];
	}
}
