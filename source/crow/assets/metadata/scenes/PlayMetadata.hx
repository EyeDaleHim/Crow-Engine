package crow.assets.metadata.scenes;

import crow.assets.metadata.game.EntityMetadata;
import crow.assets.metadata.scenes.SceneMetadata;
import crow.utils.AxeData;
import crow.utils.ColorData;

/**
 * The metadata for the gameplay scene.
 */
typedef PlayMetadata =
{
	> SceneMetadata,

	/**
	 * Configuration for the stage environment.
	 */
	var stage:StageMetadata;

	/**
	 * Configuration for the rhythm gameplay mechanics (Lanes, Health, Scoring).
	 */
	var gameplay:GameplayMetadata;

	/**
	 * The User Interface entities (Health bar, Score text, Time bar, Combo, etc.).
	 * 
	 * These are separate from the stage to ensure they render on top and 
	 * usually follow the HUD camera.
	 */
	var ui:Array<EntityMetadata>;
};

/**
 * Defines the visual environment for the level.
 */
typedef StageMetadata =
{
	/**
	 * The name of the stage (used for internal reference/debugging).
	 */
	var ?name:String;

	/**
	 * The default camera zoom for this stage.
	 */
	var defaultZoom:Float;

	/**
	 * A list of all entities in the stage.
	 * 
	 * This includes background sprites, foreground props, and the characters.
	 * To define a "character", simply add an Entity here with a specific name 
	 * (e.g. "opponent", "player") that matches the `noteReceiver` in the `LaneGroupData`.
	 */
	var entities:Array<EntityMetadata>;
}

/**
 * Defines the mechanics of the rhythm game session.
 */
typedef GameplayMetadata =
{
	/**
	 * Definitions for the note highways (Strum lines).
	 * Defines who sings what and how inputs are mapped.
	 */
	var laneGroups:Array<LaneGroupData>;

	/**
	 * Rules regarding health mechanics.
	 */
	var health:HealthRules;

	/**
	 * The number of countdown ticks before the song starts.
	 * Default is 4 (Three, Two, One, Go!).
	 */
	var ?countdownTicks:Int;
}

/**
 * Rules for how health is managed during gameplay.
 */
typedef HealthRules =
{
	/**
	 * Maximum health value. Usually 2.0 (representing 100% on a bi-directional bar).
	 */
	var max:Float;

	/**
	 * Starting health value. Usually 1.0 (50%).
	 */
	var start:Float;

	/**
	 * If true, the player loses the level if health drops to 0 or below.
	 */
	var canDie:Bool;

	/**
	 * Defines custom logic script IDs to run when health changes (hits/misses).
	 * If null, standard behavior is used.
	 */
	var ?customDrainLogic:String; 
}

/**
 * The metadata for a group of lanes (A Strum Line).
 * Represents one "singer's" set of inputs and notes.
 */
typedef LaneGroupData =
{
	/**
	 * Unique ID for this lane group (e.g., "player_strums", "opponent_strums").
	 */
	var id:String;

	/**
	 * The name of the Entity in the Stage's entity list that receives events from this lane.
	 * 
	 * When a note is hit (or missed), the engine looks for an entity with this name
	 * and triggers the corresponding animation (e.g. "singLEFT").
	 * 
	 * If a note has a `noteReceiver` as well, that one takes priority.
	 */
	var ?noteReceiver:String;

	/**
	 * If true, this lane group is controlled by the CPU (Auto-play).
	 */
	var cpuControl:Bool;

	/**
	 * The starting position of this strum line on screen.
	 */
	var position:AxeData<Float>;

	/**
	 * The spacing between each note lane.
	 */
	var spacing:Float;

	/**
	 * The default note skin to use for notes in this group.
	 * (e.g. "default", "pixel", "circle").
	 */
	var skin:String;

	/**
	 * The list of individual lanes (Keys) in this group.
	 * For standard 4-key gameplay, this array contains 4 definitions.
	 */
	var lanes:Array<LaneData>;
};

/**
 * The visual and functional data for a single lane (Key/Receptor).
 */
typedef LaneData =
{
	/**
	 * The Input Action ID defined in InputMetadata that triggers this lane.
	 * e.g., "note_left", "note_down", "note_up", "note_right".
	 * 
	 * Required if `cpuControl` is false.
	 */
	var ?inputAction:String;

	/**
	 * The direction index for this lane.
	 * Used to determine which animation suffix to play on the `noteReceiver`.
	 * (0=LEFT, 1=DOWN, 2=UP, 3=RIGHT usually).
	 */
	var directionIndex:Int;

	/**
	 * The visual angle of the receptor arrow in degrees.
	 */
	var angle:Float;

	/**
	 * The base color/tint for notes in this lane.
	 * Used if the note skin supports dynamic coloring.
	 */
	var ?color:ColorData;
};