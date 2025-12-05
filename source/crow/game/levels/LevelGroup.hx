package crow.game.levels;

import crow.assets.metadata.levels.LevelGroupData;
import crow.assets.metadata.helpers.TranslatableString;
import crow.logics.evaluators.PredicateEvaluator;
import crow.logics.evaluators.LogicEvaluator;

/**
 * A container for multiple Levels.
 * Typically represents a "Song" entity in UI, containing its variations.
 */
class LevelGroup
{
	public var id(default, null):String;
	public var data(default, null):LevelGroupData;

	/**
	 * The levels contained in this group (The variations/difficulties).
	 */
	public var levels:Array<Level>;

	public var title:TranslatableString;

	public function new(data:LevelGroupData)
	{
		this.data = data;
		this.id = data.id;
		this.title = data.displayName ?? id;
		this.levels = [];
	}

	public function addLevel(level:Level):Void
	{
		if (level != null)
			levels.push(level);
	}

	/**
	 * Checks if this group should be visible based on predicates.
	 */
	public function isVisible():Bool
	{
		return PredicateEvaluator.evaluate(data.displayCondition, LogicEvaluator.globalState);
	}

	/**
	 * Gets a specific metadata value from metaInfo (e.g. "color", "icon").
	 */
	public function getMeta(key:String):String
	{
		if (data.metaInfo == null)
			return null;
		return Reflect.field(data.metaInfo, key);
	}

	public function toString():String
	{
		return 'LevelGroup(id: $id, title: "$title", levels: ${levels.length})';
	}
}
