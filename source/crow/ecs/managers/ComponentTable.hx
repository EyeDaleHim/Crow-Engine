package crow.ecs.managers;

import crow.assets.metadata.game.ComponentMetadata;
import crow.ecs.components.BaseComponent;
import crow.ecs.components.*;

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
		var  type = list.get(metadata.name);

		if (type == null)
		{
			trace('WARNING: Component "${metadata.name}" not found. Using BaseComponent.');
			type = BaseComponent;
		}

		var component = switch (type)
		{
			case FieldLerpComponent:
				{
					final targetField:String = metadata.struct.targetField;
					final to:Float = metadata.struct.to;
					final lerpPower:Float = metadata.struct.lerpPower;
					new FieldLerpComponent(entity, targetField, to, lerpPower);
				}
			case PositionComponent:
				{
					final x:Float = metadata.struct.x;
					final y:Float = metadata.struct.y;
					new PositionComponent(entity, x, y);
				}
			case TagComponent:
				{
					final tags:Array<String> = metadata.struct.tags;
					new TagComponent(tags);
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
}
