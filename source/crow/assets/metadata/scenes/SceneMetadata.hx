package crow.assets.metadata.scenes;

import crow.assets.metadata.logics.LogicMetadata;

/**
 * The base structure for all scene metadata.
 */
typedef SceneMetadata =
{
	/**
	 * A map of custom data to be stored and processed.
	 */
	var ?storedData:Dynamic;

	/**
	 * Logic properties for the menu, including initial state and listeners.
	 */
	var ?logic:LogicMetadata;

	/**
	 * Defines asset contexts to be loaded or unloaded with the scene.
	 */
	var ?contexts:SceneContexts;

	/**
	 * Defines how transitions are handled for a scene state.
	 */
	var ?transitions:SceneTransitions;

	/**
	 * The cameras to define for this scene.
	 * 
	 * Note that "_main" will always refer to FlxG.camera, if you create a camera named
	 * "_main", FlxG.camera will be overwritten by this camera.
	 * 
	 * If left empty, this is equivalent to {name: "_main"}.
	 * 
	 * If "_main" is not found, it is automatically created and inserted
	 * at the first index of the array.
	 */
	var ?cameras:SceneCameras;
};

typedef SceneCameras = Array<SceneCamera>;

typedef SceneCamera = {
	/**
	 * The name of this camera.
	 * 
	 * If the name is "_main", FlxG.camera will be overwritten by this camera.
	 * 
	 * If there is already an existing camera of this name, the game will throw.
	 */
	var name:String;

	/**
	 * The position of this camera.
	 * Default is {x: 0, y: 0}
	 */
	var ?position:AxeData<Float>;

	/**
	 * The size of this camera.
	 * Default is {x: FlxG.width, y: FlxG.height}
	 */
	var ?size:AxeData<Int>;

	/**
	 * The scroll of this camera, in this case this is the coordinates for
	 * the top-left corner of the camera in world space.
	 * Default is {x: 0, y: 0}
	 */
	var ?scroll:AxeData<Float>;

	/**
	 * The zoom level of this camera.
	 * Default is 1.
	 */
	var ?zoom:Float;
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
