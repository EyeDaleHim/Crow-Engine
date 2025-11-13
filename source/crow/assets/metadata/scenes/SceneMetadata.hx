package crow.assets.metadata.scenes;

/**
 * The base structure for all scene metadata.
 */
typedef SceneMetadata =
{
    /**
	 * Defines asset contexts to be loaded or unloaded with the scene.
	 */
	var ?contexts:SceneContexts;

	/**
	 * Defines how transitions are handled for a scene state.
	 */
	var ?transitions:SceneTransitions;
};

/**
 * Defines asset contexts to be loaded or unloaded with the scene.
 * These are processed by the state that loads the scene metadata.
 */
typedef SceneContexts =
{
	/**
	 * A list of asset context names to load when the scene is created.
	 */
	var ?load:Array<String>;

	/**
	 * A list of asset context names to unload when the scene is destroyed.
	 */
	var ?unload:Array<String>;
};

/**
 * Defines how transitions are handled for a scene state.
 */
typedef SceneTransitions =
{
	/**
	 * If `true`, skips the transition when the state is first entered.
	 */
	var ?skipIn:Bool;

	/**
	 * If `true`, skips the transition when returning to this state from a sub-state.
	 */
	var ?skipReturn:Bool;

	/**
	 * If `true`, skips the transition when leaving this state.
	 */
	var ?skipOut:Bool;
};