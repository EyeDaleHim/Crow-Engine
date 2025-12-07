package crow.ecs.components;

import crow.ecs.components.BaseComponent;

/**
 * A reference component for things like `DynamicListLayout` to
 * set values to which member within entities without using any 
 * filters.
 * 
 * This has no system equivalent.
 */
class ValueRouterComponent extends BaseComponent
{
    public var target:String;
	public var field:String;

	public function new(target:String, field:String)
	{
		this.target = target;
		this.field = field;
	}

	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Multi;
	}
}
