package crow.game.levels;

import crow.assets.AssetPaths;
import crow.assets.metadata.internals.MasterListMetadata;
import crow.assets.metadata.levels.LevelData;
import crow.assets.metadata.levels.LevelGroupData;
import haxe.io.Path;

/**
 * The central manager for all level-related data.
 * Loads the Master List, Groups, and atomic Levels.
 */
class LevelRegistry
{
	public static final MASTER_LIST_PATH = "data/config/master_levels";
	public static final GROUPS_PATH = "data/gameplay/groups";
	public static final LEVELS_PATH = "data/gameplay/levels";

	/**
	 * All registered groups, keyed by ID.
	 */
	public var groups:Map<String, LevelGroup>;

	/**
	 * All registered levels, keyed by ID.
	 */
	public var levels:Map<String, Level>;

	/**
	 * The sorted list of Group IDs as defined by the Master List.
	 */
	public var sortedGroupIDs:Array<String>;

	/**
	 * Playlists defined in the master list.
	 * Key = Playlist ID, Value = Array of IDs (usually Group IDs or Level IDs).
	 */
	public var playlists:Map<String, Array<String>>;

	public function new()
	{
		groups = new Map();
		levels = new Map();
		sortedGroupIDs = [];
		playlists = new Map();

		loadRegistry();
	}

	public function loadRegistry():Void
	{
		// 1. Load Master List to get order and definitions
		if (!Main.assets.exists(Path.withExtension(MASTER_LIST_PATH, AssetPaths.jsonExt)))
		{
			trace("LevelRegistry: Master list not found at " + MASTER_LIST_PATH);
			return;
		}

		var masterMeta:MasterListMetadata = Main.assets.json(MASTER_LIST_PATH);
		if (masterMeta == null)
		{
			trace("LevelRegistry: No master list found at " + MASTER_LIST_PATH);
			return;
		}

		if (masterMeta.groups != null)
			sortedGroupIDs = masterMeta.groups;

		if (masterMeta.playlists != null)
		{
			for (playlist in masterMeta.playlists)
			{
				if (playlist.id != null && playlist.content != null)
				{
					playlists.set(playlist.id, playlist.content);
				}
			}
		}

		// 2. Load all Groups defined in the master list
		for (groupId in sortedGroupIDs)
		{
			loadGroup(groupId);
		}

		// 3. Resolve internal level references for loaded groups
		for (group in groups)
		{
			if (group.data.levels == null)
				continue;

			for (levelId in group.data.levels)
			{
				var lvl = loadLevel(levelId);
				group.addLevel(lvl);
			}
		}
	}

	private function loadGroup(id:String):LevelGroup
	{
		if (groups.exists(id))
			return groups.get(id);

		var path = Path.join([GROUPS_PATH, id]);
		var data:LevelGroupData = Main.assets.json(path);

		if (data == null)
		{
			trace('LevelRegistry: Group metadata not found for "$id"');
			return null;
		}

		var group = new LevelGroup(data);
		groups.set(id, group);
		return group;
	}

	private function loadLevel(id:String):Level
	{
		if (levels.exists(id))
			return levels.get(id);

		var path = Path.join([LEVELS_PATH, id]);
		var data:LevelData = Main.assets.json(path);

		if (data == null)
		{
			trace('LevelRegistry: Level metadata not found for "$id"');
			return null;
		}

		var level = new Level(data);
		levels.set(id, level);
		return level;
	}

	public function getGroup(id:String):LevelGroup
		return groups.get(id);

	public function getLevel(id:String):Level
		return levels.get(id);

	/**
	 * Gets a playlist configuration by ID.
	 */
	public function getPlaylistContent(id:String):Array<String>
	{
		return playlists.get(id);
	}
}
