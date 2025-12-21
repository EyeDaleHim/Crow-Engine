package crow.assets.metadata.levels;

import crow.assets.metadata.levels.LevelData;
import crow.assets.metadata.logics.PredicateMetadata;

/**
 * Data about a collection of levels.
 * Typically represents a "song" which contains multiple "variations" (levels).
 */
typedef LevelGroupData =
{
	> LevelInfoData,

	/**
	 * The unique ID of the level group.
	 */
	var id:String;

	/**
	 * The list of Level IDs in this group, referenced by their internal ID.
	 * These act as the "options" or "difficulties" for this group.
	 * 
	 * Each object in this field will refer to a `LevelData`.
	 */
	var levels:Array<String>;

	/**
	 * The predicate required for this group to be visible.
	 */
	var ?displayCondition:PredicateMetadata;
};
