package crow.logics.templates;

import crow.entities.Entity;
import crow.logics.dependencies.LogicState;
import crow.logics.evaluators.LogicEvaluator;
import crow.logics.templates.Template;
import crow.objects.layout.InteractableLayout;
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
				if (formerItem == null)
					return; // Should not happen if the layout has selectable items

				final formerEntity = menuState.entities.get(formerItem.name);

				final amount:Int = ctx.values.direction ?? 0;
				targetLayout.changeSelection(amount);

				final localState = ctx.localState ?? new LogicState();

				if (formerItem.onDeselect != null)
				{
					localState.set("index", targetLayout.members.indexOf(formerObject));
					menuState.handleMenuAction(formerItem.onDeselect, formerItem, formerEntity, localState);
				}

				final selectedObject = targetLayout.selectedObject;
				final selectedItem = menuState.elementMetadataMap.get(selectedObject);
				if (selectedItem == null)
					return; // Should not happen
				final selectedEntity = menuState.entities.get(selectedItem.name);

				if (selectedItem.onSelect != null)
				{
					localState.set("index", targetLayout.selectedIndex);
					menuState.handleMenuAction(selectedItem.onSelect, selectedItem, selectedEntity, localState);
				}

				if (ctx.localState != null)
				{
					ctx.localState.clear();
				}

				if (selectedItem.onIndex != null)
				{
					localState.set("oldIndex", targetLayout.members.indexOf(formerObject));
					localState.set("newIndex", targetLayout.selectedIndex);

					menuState.handleMenuAction(selectedItem.onIndex, selectedItem, selectedEntity, localState);
				}
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
					if (selectedItem?.onAccept != null)
					{
						final selectedEntity = menuState.entities.get(selectedItem.name);
						menuState.handleMenuAction(selectedItem.onAccept, selectedItem, selectedEntity, menuState.logicState);
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
			}, [], {wantsExecutor: true})
		];
	}
}
