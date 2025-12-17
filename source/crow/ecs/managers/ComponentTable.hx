package crow.ecs.managers;

import crow.logics.dependencies.LogicContext;
import crow.assets.metadata.game.ComponentMetadata;
import crow.ecs.components.BaseComponent;
import crow.ecs.components.*;
import crow.logics.tools.StringInterpolator;

class ComponentTable
{
	public static final list:Map<String, Class<IComponent>> = [];

	/**
	 * Initializes the table.
	 */
	public static function init():Void
	{
		list.set("field_lerp", FieldLerpComponent);
		list.set("position", PositionComponent);
		list.set("tags", TagComponent);
		list.set("value_router", ValueRouterComponent);
	}

	/**
	 * Creates a component from metadata.
	 *
	 * @param metadata The `ComponentMetadata` to create the component from.
	 * @param entity The entity to attach the component to.
	 * @return IComponent The created component.
	 */
	@:generic
	public static function fromMetadata<T:IComponent>(metadata:ComponentMetadata, entity:Entity):IComponent
	{
		var type = list.get(metadata.name);

		if (type == null)
		{
			trace('WARNING: Component "${metadata.name}" not found. Using BaseComponent.');
			type = BaseComponent;
		}

		var component = switch (type)
		{
			case FieldLerpComponent:
				{
					final targetField:String = resolve(metadata.struct.targetField, entity);
					final to:Float = resolve(metadata.struct.to, entity);
					final lerpPower:Float = resolve(metadata.struct.lerpPower, entity);
					new FieldLerpComponent(entity, targetField, to, lerpPower);
				}
			case PositionComponent:
				{
					final x:Float = resolve(metadata.struct.x, entity);
					final y:Float = resolve(metadata.struct.y, entity);
					new PositionComponent(entity, x, y);
				}
			case TagComponent:
				{
					final tags:Array<String> = resolve(metadata.struct.tags, entity);
					new TagComponent(tags);
				}
			case ValueRouterComponent:
				{
					final target:String = resolve(metadata.struct.target, entity);
					final field:String = resolve(metadata.struct.field, entity);
					new ValueRouterComponent(target, field);
				}
			default:
				Type.createEmptyInstance(BaseComponent);
		};
		component.entity = entity;

		if (metadata.id != null)
		{
			component.name = metadata.id;
		}

		return (component : IComponent);
	}

	private static function resolve(value:Dynamic, entity:Entity):Dynamic
	{
		if (Std.isOfType(value, String))
		{
			final strVal:String = cast value;
			if (strVal.indexOf("${") != -1)
			{
				var ctx = LogicContext.createLegacy(crow.logics.evaluators.LogicEvaluator.globalState, null, entity.logicState);

				var resolved = StringInterpolator.interpolate(strVal, ctx);

				// Attempt to convert back to typed values since Interpolator returns Strings
				var f = Std.parseFloat(resolved);
				if (!Math.isNaN(f))
				{
					// It's a number
					if (resolved.indexOf(".") == -1)
						return Std.parseInt(resolved);
					return f;
				}
				if (resolved == "true")
					return true;
				if (resolved == "false")
					return false;

				return resolved;
			}
		}
		// Return array as-is, maybe handle deep resolution later?
		return value;
	}
}
