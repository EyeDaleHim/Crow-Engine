package crow.ecs.components;

import crow.ecs.components.BaseComponent;
import crow.ecs.entities.Model;

/**
 * Mandatory component for the visual display in entities.
 */
class ModelComponent extends BaseComponent
{
	public var model:Model;

	public function new(entity:Entity)
	{
		this.entity = entity;
		model = new Model(entity);
	}

	override function get_trait():ComponentTrait
	{
		return ComponentTrait.Single;
	}
}
