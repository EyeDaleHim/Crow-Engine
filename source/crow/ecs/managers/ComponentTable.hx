package crow.ecs.managers;

import crow.ecs.components.BaseComponent;
import crow.ecs.components.*;

class ComponentTable
{
    public static final list:Map<String, Class<IComponent>> = [];

    public static function init():Void
    {
        list.set("field_lerp", FieldLerpComponent);
        list.set("position", PositionComponent);
        list.set("tags", TagComponent);
    }
}