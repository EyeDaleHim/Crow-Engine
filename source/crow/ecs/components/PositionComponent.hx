package crow.ecs.components;

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
}
