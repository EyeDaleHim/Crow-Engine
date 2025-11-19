package crow.ecs.entities;

import crow.ecs.components.BaseComponent;

interface IComponentActor
{
	public var components:Array<IComponent>;

	public function getComponentByType(type:Class<IComponent>):IComponent;
	public function getComponentsByType(type:Class<IComponent>, ?filter:IComponent->Bool):Array<IComponent>;
	public function getComponentByName(name:String):IComponent;
	public function getComponentsByName(name:String, ?filter:IComponent->Bool):Array<IComponent>;

	public function addComponent(component:IComponent):Void;
	public function addComponents(components:Array<IComponent>, ?filter:IComponent->Bool):Void;
	
	public function removeComponent(component:IComponent):Void;
	public function removeComponents(components:Array<IComponent>, ?filter:IComponent->Bool):Void;
	public function removeComponentsByType(type:Class<IComponent>, ?filter:IComponent->Bool):Void;
}
