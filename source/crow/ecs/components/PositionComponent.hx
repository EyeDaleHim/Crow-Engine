package crow.ecs.components;

import crow.ecs.components.BaseComponent;

/**
 * Represents the position of an entity in 2D space.
 */
class PositionComponent extends BaseComponent
{
	/**
	 * The x-coordinate of the entity, in world space.
	 */
	public var x:Float;

	/**
	 * The y-coordinate of the entity, in world space.
	 */
	public var y:Float;

	/**
	 * Whether to mark the position as dirty.
	 * 
	 * This is typically managed by the entity itself and
	 * should be `false` by the time the entity is done updating.
	 */
	public var dirty:Bool = false;

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
