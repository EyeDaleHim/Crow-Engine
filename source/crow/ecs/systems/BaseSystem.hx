package crow.ecs.systems;

import crow.ecs.components.BaseComponent;
import crow.logics.dependencies.IEventExecutor;

class BaseSystem implements ISystem
{
	private var _weakComponents:Array<IComponent> = [];

	/**
	 * Process a single entity.
	 * @param entity The entity to process.
	 * @param elapsed The elapsed time since the last frame.
	 */
	public function processEntity(entity:Entity, elapsed:Float):Void
	{
		// Base implementation does nothing.
	}

	public function postProcessComponent(processedComponent:IComponent):Void
	{
		if (processedComponent?.trait.has(ComponentTrait.Weak))
		{
			_weakComponents.push(processedComponent);
		}
	}

	/**
	 * Called once when the system is added to the state.
	 */
	public function onAdd():Void {}

	/**
	 * Called once when the system is removed from the state.
	 */
	public function onRemove():Void {}

	/**
	 * Called every frame before entities are processed (optional).
	 */
	public function preUpdate(elapsed:Float):Void {}

	/**
	 * Called every frame after all entities are processed (optional).
	 */
	public function postUpdate(elapsed:Float):Void {}
}

interface ISystem
{
	private var _weakComponents:Array<IComponent>;

	function onAdd():Void;
	function onRemove():Void;
	function processEntity(entity:Entity, elapsed:Float):Void;
	function postProcessComponent(processedComponent:IComponent):Void;
	function preUpdate(elapsed:Float):Void;
	function postUpdate(elapsed:Float):Void;
}
