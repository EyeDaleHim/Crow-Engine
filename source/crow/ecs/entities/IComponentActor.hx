package crow.ecs.entities;

import crow.ecs.components.BaseComponent;

interface IComponentActor
{
	public var components:OrderedMap<Class<IComponent>, IComponent>;

	public function getComponentByType(type:Class<IComponent>):IComponent;
	public function getComponentsByType(type:Class<IComponent>):Array<IComponent>;

	public function addComponent(component:IComponent):Void;
	public function addComponents(components:Array<IComponent>):Void;
	public function removeComponents(components:Array<IComponent>, ?filter:IComponent->Bool):Void;
	public function removeComponentsByType(type:Class<IComponent>, ?filter:IComponent->Bool):Void;
}
