package crow.logics.templates;

import crow.assets.metadata.logics.ComponentFilterMetadata;
import crow.assets.metadata.logics.PredicateMetadata;
import crow.ecs.components.BaseComponent.IComponent;
import crow.ecs.managers.ComponentTable;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.Template;

class ComponentTemplate extends Template
{
	public function actions():Map<String, ExecutableAction>
	{
		return [
			/**
			 * Modifies a field on components attached to targeted entities with granular filtering.
			 */
			"set_component_field" => ExecutableAction.createAction((ctx) ->
			{
				final identifier:String = ctx.values.component; // Class name (e.g., "field_lerp") OR Instance Name
				final fieldName:String = ctx.values.field; // Field to change (e.g., "to")
				final newValue:Dynamic = ctx.values.value; // New Value

				final filter:Dynamic = ctx.values.filter;

				// Resolve Class Type if possible
				var componentClass:Class<IComponent> = ComponentTable.list.get(identifier);

				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					// gather candidates
					var candidates:Array<IComponent> = [];

					if (componentClass != null)
					{
						// It's a Type (e.g. "field_lerp"), get all of them
						candidates = entity.getComponentsByType(componentClass);
					}
					else
					{
						// It's a specific Name/ID, try to find it
						// Note: We search all components because getComponentByName returns singular
						candidates = entity.getComponentsByName(identifier);
					}

					// 2. Filter Candidates
					for (comp in candidates)
					{
						if (shouldModifyComponent(comp, filter, ctx.executorState, entity.logicState))
						{
							applyChange(comp, fieldName, newValue);
						}
					}
				});
				ctx.onComplete();
			}, [
					{name: "component", type: "String", optional: false},
					{name: "field", type: "String", optional: false},
					{name: "value", type: "Dynamic", optional: false},
					{name: "filter", type: "Dynamic", optional: true}
			], {wantsTargetedEntities: true})
		];
	}

	private function shouldModifyComponent(comp:IComponent, filter:ComponentFilterMetadata, globalState:LogicState, entityState:LogicState):Bool
	{
		if (filter == null)
			return true;

		if (filter.customTrait != null)
		{
			if (comp.customTrait != filter.customTrait)
				return false;
		}

		if (filter.condition != null)
		{
			var proxyState = new ComponentProxyState(comp);

			if (!PredicateEvaluator.evaluate(filter.condition, globalState, proxyState, entityState))
			{
				return false;
			}
		}

		return true;
	}

	private function applyChange(comp:IComponent, field:String, value:Dynamic):Void
	{
		try
		{
			if (Reflect.getProperty(comp, field) != null || Reflect.hasField(comp, field))
			{
				Reflect.setProperty(comp, field, value);
			}
			else
			{
				trace('Warning: Field "$field" not found on component "${comp.name}"');
			}
		}
		catch (e)
		{
			trace('Error setting component field: $e');
		}
	}
}

/**
 * A lightweight wrapper that tricks LogicState into reading directly from a Component object.
 * This allows Predicates to check component values (like "x", "to", "visible") without copying data.
 */
private class ComponentProxyState extends LogicState
{
	public var target:Dynamic;

	public function new(target:Dynamic)
	{
		super();
		this.target = target;
	}

	override public function get(key:String):Dynamic
	{
		var prop = Reflect.getProperty(target, key);
		if (prop != null)
			return prop;

		return super.get(key);
	}

	override public function exists(key:String):Bool
	{
		if (Reflect.hasField(target, key))
			return true;
		return super.exists(key);
	}
}
