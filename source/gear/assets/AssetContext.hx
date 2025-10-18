package gear.assets;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import gear.assets.paths.PathDirectoryStruct;
import gear.assets.paths.PathFileStruct;
import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;
import flixel.FlxG;
import haxe.io.Path;

/**
 * An AssetContext allows to load and unload certain assets, an asset's existence in the cache
 * is often retained as long as one AssetContext containing that asset's entry is still active.
 * 
 * AssetContexts can be populated with a JSON file.
 */
class AssetContext
{
	public static var contextDirectory:String = "contexts";
	public static var dirtyContexts:Bool = false;

	public var name(default, null):String;
	public var entries(default, null):AssetContextFile;

	public function new(file:String)
	{
		this.name = file;

		final rawJson = FlxG.assets.getText(Path.join([contextDirectory, '$file.json']));
		if (rawJson == null)
		{
			this.entries = [];
			return;
		}

		var rawEntries:AssetContextFile = Json.parse(rawJson);
		this.entries = [];

		for (entry in rawEntries)
		{
			if (entry.files != null)
			{
				this.entries.push({files: entry.files});
			}

			if (entry.directories != null)
			{
				for (dirPath in entry.directories.paths)
				{
					addDirectoryFiles(dirPath, entry.directories.recursive, entry.directories.type);
				}
			}
		}

		final uniqueEntries = new Map<String, AssetContextEntry>();
		for (entry in this.entries)
		{
			if (entry.files != null)
			{
				uniqueEntries.set(entry.files.path, entry);
			}
		}
		this.entries = [for (entry in uniqueEntries) entry];
	}

	private function addDirectoryFiles(directory:String, recursive:Bool, ?type:FlxAssetType):Void
	{
		if (!Assets.exists(directory) || !Assets.isList(directory))
			return;

		for (fileName in Assets.list(directory))
		{
			final fullPath = Path.join([directory, fileName]);
			if (Assets.isList(fullPath))
			{
				if (recursive)
				{
					addDirectoryFiles(fullPath, true, type);
				}
			}
			else
			{
				entries.push({files: {path: fullPath, type: type}});
			}
		}
	}

	public function findAsset(fullPath:String):Bool
	{
		for (entry in entries)
		{
			if (entry.files != null)
			{
				if (entry.files.path == fullPath)
				{
					return true;
				}
			}
		}

		return false;
	}
}

typedef AssetContextFile = Array<AssetContextEntry>;

typedef AssetContextEntry =
{
	var ?files:PathFileStruct;
	var ?directories:PathDirectoryStruct;
};
