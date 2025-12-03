package crow.ecs.components;

import crow.ecs.components.BaseComponent;

class PositionalIndexComponent extends BaseComponent
{
	/**
	 * The index of this entity.
	 */
	public var index:Int = 0;

	public function new(?index:Int = 0)
	{
		this.index = index;
	}

	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Single;
	}
}
