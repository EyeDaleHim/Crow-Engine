package crow.assets.metadata.levels;

import crow.assets.metadata.logics.PredicateMetadata;
import crow.assets.metadata.scenes.SceneMetadata;

/**
 * Base information shared between Levels and Groups.
 */
typedef LevelInfoData =
{
	/**
	 * The display name.
	 * For a LevelGroup, this is the Song Name (e.g. "Dadbattle").
	 * For a Level, this is the Variation/Difficulty Name (e.g. "Hard", "Remix").
	 */
	var ?displayName:String;

	/**
	 * The contexts to load, if any.
	 */
	var ?contextsToLoad:Array<String>;

	/**
	 * The contexts to unload, if any.
	 */
	var ?contextsToUnload:Array<String>;

	/**
	 * Additional meta about the object.
	 * Keys can include "artist", "char_icon", "color", etc.
	 */
	var ?metaInfo:Dynamic<String>;
};

typedef LevelAudioData = 
{
    /**
     * The track to identify as the main track, requires
	 * `channels` to be defined. Use the track's `id`.
     */
    var mainTrack:String;

    /**
     * The list of audio channels for this level.
     */
    var channels:Array<LevelTrackData>;
}

typedef LevelTrackData =
{
	/**
	 * The unique ID of the track.
	 */
	var id:String;

	/**
	 * The path to the track's audio file.
	 * Note that it will be prefixed at runtime.
	 */
	var path:String;
};

/**
 * Data about a single, atomic playable level.
 * This represents a specific chart and its audio.
 */
typedef LevelData =
{
	> LevelInfoData,

	/**
	 * The unique ID of the level. It is important for the ID
	 * to be unique.
	 */
	var id:String;

	/**
	 * The path to the chart JSON file.
	 */
	var chartPath:String;

    /**
     * The audio tracks associated with this level.
     */
    var audio:LevelAudioData;

	/**
	 * The scene to load if the chart does not specify one.
	 * 
	 * If the scene is still not defined, you would be left with a
	 * black stage with no entities.
	 */
	var ?scenePath:String;
	
	/**
	 * The predicate required for this level to be selectable.
	 */
	var ?displayCondition:PredicateMetadata;
};