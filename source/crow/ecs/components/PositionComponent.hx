package crow.ecs.components;

import crow.ecs.components.BaseComponent;

/**
 * Represents the position of an entity in 2D space.
 */
class PositionComponent extends BaseComponent
{
	public var x:Float;
	public var y:Float;

	public function new(entity:Entity, x:Float, y:Float)
	{
		this.entity = entity;
		this.x = x;
		this.y = y;
	}

	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Single;
	}
}
