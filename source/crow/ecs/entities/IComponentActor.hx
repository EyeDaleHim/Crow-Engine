package crow.ecs.entities;

import crow.ecs.components.BaseComponent;

interface IComponentActor
{
	public var components:Array<IComponent>;

	public function getComponentByType(type:Class<IComponent>):IComponent;
	public function getComponentsByType(type:Class<IComponent>):Array<IComponent>;
}
