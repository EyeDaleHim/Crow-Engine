package crow.states.internals;

import crow.assets.AssetContext;
import crow.assets.metadata.levels.GameStemData;
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

	/**
	 * The loading screen.
	 * This is the background image for the loading screen.
	 */
	public var loadingScreenBackground:FlxSprite;

	/**
	 * This is the loading screen text.
	 */
	public var loadingScreenText:FlxText;

	/**
	 * This is the logo for the loading screen.
	 */
	public var loadingScreenLogo:FlxSprite;

	/**
	 * This is the progress bar for the loading screen.
	 */
	public var loadingScreenProgress:FlxSprite;

	/**
	 * The camera for the loading screen.
	 */
	public var loadingScreenCamera:FlxCamera;

	public var tweenManager:TweenManager;
	public var timerManager:TimerManager;

	/**
	 * All the merged asset contexts to load.
	 */
	private var _contextToLoadBuffer:Array<AssetContext> = [];

	public function new()
	{
		super();

		music = new Music();
		add(music);

		timerManager = new TimerManager();
		tweenManager = new TweenManager();
	}

	/**
	 * Prepares the PlayState for a new game session based on the provided `GameStemData`.
	 * @param gameStem  The data that defines the game session, including the level or playlist to load.
	 */
	public function prepare(gameStem:GameStemData):Void {}

	/**
	 * Starts loading all the relevant context.
	 */
	public function startLoading():Void {}

	/**
	 * Like `destroy()`, but only for the entities and data that
	 * this game session loaded, this PlayState instance should be 
	 * reusable.
	 * 
	 * This should only be called if the game is actually done
	 * with the gameplay.
	 * 
	 * The exception is the loading screen itself.
	 */
	public function clearGame():Void
	{
		for (entity in entities)
		{
			entity.destroy();
		}
		entities.clear();

		systems = [];

		for (musicChannel in musicChannels)
		{
			musicChannel.destroy();
		}
		musicChannels.clear();

		for (sound in soundInstances)
		{
			sound.destroy();
		}
		soundInstances.clear();

		timerManager.clear();
		tweenManager.clear();
	}

	public function revertLoading():Void {}

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

enum LoadingScreenPhase
{
	/**
	 * The assets are being loaded.
	 */
	LOADING_ASSETS;
	
	/**
	 * The entities are being loaded.
	 */
	LOADING_ENTITIES;
}
