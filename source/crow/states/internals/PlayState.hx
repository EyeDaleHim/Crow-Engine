package crow.states;

import crow.ds.orderedmap.OrderedStringMap;
import crow.ecs.managers.TimerManager;
import crow.ecs.managers.TweenManager;
import crow.ecs.systems.BaseSystem;
import crow.logics.dependencies.IEventExecutor;
import crow.logics.dependencies.LogicState;

/**
 * The state for where the game content happens.
 * 
 * By default, when preloaded, this only actually loads the loading screen,
 * waiting until the game is ready to start.
 */
class PlayState extends MainState implements IEventExecutor
{
	/**
	 * The music that plays during this state.
	 * In the case of PlayState, this is the primary music channel
	 * for gameplay. Though it can be used for things like
	 * cutscenes but may disrupt gameplay if one is ongoing.
	 */
	public var music:Music;

	/**
	 * A map of music channels that are currently loaded for
	 * this state.
	 */
	public var musicChannels:OrderedStringMap<Music> = new OrderedStringMap<Music>();

	/**
	 * The list of sounds that are currently loaded for
	 * this state.
	 */
	public var soundInstances:Map<String, FlxSound> = [];

	/**
	 * The entities that are currently loaded for
	 * this state.
	 */
	public var entities:OrderedStringMap<Entity> = new OrderedStringMap<Entity>();

	/**
	 * The systems that are currently loaded for
	 * this state.
	 */
	public var systems:Array<BaseSystem> = [];

	/**
	 * The current logic state of the game.
	 */
	public var logicState:LogicState;

	/**
	 * Unused, but only required by the `IEventExecutor` interface.
	 */
	public var nextScenes:Array<String>;

	public var tweenManager:TweenManager;
	public var timerManager:TimerManager;

	public function new()
	{
		super();
	}

	override function update(elapsed:Float)
	{
		for (system in systems)
			system.preUpdate(elapsed);

		super.update(elapsed);

		onEvent("update");

		for (entity in entities)
		{
			for (system in systems)
			{
				system.processEntity(entity, elapsed);
			}
		}

		for (system in systems)
			system.postUpdate(elapsed);

		for (system in systems)
		{
			@:privateAccess
			for (weak in system._weakComponents)
			{
				if (weak.entity != null)
				{
					weak.entity.removeComponent(weak);
				}
				weak.destroy();
			}

			@:privateAccess
			system._weakComponents.splice(0, system._weakComponents.length);
		}
	}

	public function switchScene(sceneName:String):Bool
	{
		return false;
	}

	public function onEvent(eventName:String, ?localState:LogicState):Void {}

	public function removeListenersByTag(tag:String):Void {}
}
