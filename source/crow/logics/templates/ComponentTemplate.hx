package crow.logics.templates;

import crow.assets.metadata.logics.ComponentFilterMetadata;
import crow.assets.metadata.logics.PredicateMetadata;
import crow.ecs.components.BaseComponent.IComponent;
import crow.ecs.managers.ComponentTable;
import crow.logics.dependencies.LogicState;
import crow.logics.templates.Template;
import crow.logics.evaluators.PredicateEvaluator;
import crow.logics.tools.ActionScope;

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
				final identifier:String = ctx.values.component; 
				final fieldName:String = ctx.values.field; 
				final newValue:Dynamic = ctx.values.value; 

				final filter:Dynamic = ctx.values.filter;

				var componentClass:Class<IComponent> = ComponentTable.list.get(identifier);

				ExecutableAction.handleEntityAction(ctx.targetedEntities, (entity) ->
				{
					var candidates:Array<IComponent> = [];

					if (componentClass != null)
						candidates = entity.getComponentsByType(componentClass);
					else
						candidates = entity.getComponentsByName(identifier);

                    // Build context for this entity
                    var entityScopes = ctx.scopes.copy();
                    entityScopes.set(ActionScope.ENTITY, entity.logicState);

					// 2. Filter Candidates
					for (comp in candidates)
					{
						if (shouldModifyComponent(comp, filter, entityScopes))
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

	private function shouldModifyComponent(comp:IComponent, filter:ComponentFilterMetadata, scopes:Map<String, LogicState>):Bool
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
            // The "local" scope in this context refers to the component proxy
			var proxyState = new ComponentProxyState("component_proxy_state", comp);
            
            var componentScopes = scopes.copy();
            componentScopes.set(ActionScope.LOCAL, proxyState);

			if (!PredicateEvaluator.evaluate(filter.condition, componentScopes))
			{
				return false;
			}
		}

		return true;
	}

    // ... [applyChange and ComponentProxyState remain unchanged] ...
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

private class ComponentProxyState extends LogicState
{
	public var target:Dynamic;

	public function new(name:String, target:Dynamic)
	{
		super(name);
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