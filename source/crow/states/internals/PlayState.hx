package crow.states.internals;

import crow.assets.AssetContext;
import crow.assets.metadata.levels.GameStemData;
import crow.ds.orderedmap.OrderedStringMap;
import crow.ecs.managers.TimerManager;
import crow.ecs.managers.TweenManager;
import crow.ecs.systems.BaseSystem;
import crow.game.session.Session;
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
	 * The current session of the game.
	 */
	public var session:Session;

	private var _contextToLoadBuffer:Array<String> = [];
	private var _contextToUnloadBuffer:Array<String> = [];

	public var tweenManager:TweenManager;
	public var timerManager:TimerManager;

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
	public function prepare(gameStem:GameStemData):Void
	{
		clearGame();

		session = new Session(gameStem);

		if (session.currentLevel == null)
		{
			trace("ERROR: No current level in session after initialization.");
			return;
		}

		// Load the chart data for the current level
		if (!session.currentLevel.loadChart())
		{
			trace('ERROR: Failed to load chart for level "${session.currentLevel.id}"');
			return;
		}

		// Merge contexts from the level and its scene metadata

		// Add level-specific contexts
		if (session.currentLevel.data.contextsToLoad != null)
		{
			_contextToLoadBuffer = _contextToLoadBuffer.concat(session.currentLevel.data.contextsToLoad);
		}
		if (session.currentLevel.data.contextsToUnload != null)
		{
			_contextToUnloadBuffer = _contextToUnloadBuffer.concat(session.currentLevel.data.contextsToUnload);
		}

		// Add scene-specific contexts
		if (gameStem.scene != null)
		{
			if (gameStem.scene.contexts != null)
			{
				if (gameStem.scene.contexts.load != null)
				{
					_contextToLoadBuffer = _contextToLoadBuffer.concat(gameStem.scene.contexts.load);
				}
				if (gameStem.scene.contexts.unload != null)
				{
					_contextToUnloadBuffer = _contextToUnloadBuffer.concat(gameStem.scene.contexts.unload);
				}
			}
		}
	}

	/**
	 * Starts loading all the relevant context and session.
	 */
	public function startLoading(?async:Bool = true):Void
	{
		#if !USE_MULTITHREADING
		async = false;
		#end

		if (_contextToLoadBuffer.length == 0)
		{
			trace("No asset contexts to load for this session.");
			return;
		}

		handleContexts({
			load: _contextToLoadBuffer,
			unload: _contextToUnloadBuffer
		}, async, () ->
			{
				// All contexts are loaded, now proceed with game initialization
				trace("All contexts loaded. Initializing game...");

				createScene(async);

				// For now, just transition out the loading screen
				trace("Game ready!");
			});
	}

	public function createScene(async:Bool = true):Void
	{
		#if !USE_MULTITHREADING
		async = false;
		#end


	}

	/**
	 * Like `destroy()`, but only for the entities and data that
	 * this game session loaded, this PlayState instance should be 
	 * reusable.
	 * 
	 * This should only be called if the game is actually done
	 * with the gameplay.
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
