package gear.assets;

import haxe.Json;
import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;
import flixel.FlxG;
import haxe.io.Path;

/**
 * An AssetContext allows to load and unload certain assets, an asset's existence in the cache
 * is often retained as long as one AssetContext containing that asset's entry is still active.
 * 
 * The best practice is that every asset must be associated with a context, any asset without a
 * context is considered an orphaned asset and may face redundant unloading and loading, 
 * this is a deliberate opinion to avoid bad habits and inconsistencies. You can automate
 * preventing orphaned assets by setting `enforceAssetContext` to true.
 * 
 * AssetContexts can be populated with a JSON file.
 */
class AssetContext
{
	public static var contextDirectory:String = "contexts";

	public static var dirtyContexts:Bool = false;
	public static var enforceAssetContext:Bool = false; // TODO: implement

	public var name(default, null):String;
	public var entries(default, null):Array<AssetEntry>;

	public function new(file:String)
	{
		this.name = file;

		final rawJson = FlxG.assets.getTextUnsafe(Path.join([contextDirectory, '$file.json']));
		if (rawJson == null)
		{
			this.entries = [];
			return;
		}

		try
		{
			var parsedEntries:Array<AssetEntry> = cast Json.parse(rawJson);
			final uniqueEntries = new Map<String, AssetEntry>();
			for (entry in parsedEntries)
			{
				// The `type` from JSON is a string, we need to convert it to FlxAssetType enum
				final assetType:FlxAssetType = switch (cast(entry.type, String).toLowerCase().trim())
				{
					case "image": IMAGE;
					case "sound": SOUND;
					case "text": TEXT;
					case "font": FONT;
					case "binary": BINARY;
					default: null;
				}

				uniqueEntries.set(entry.path, {path: entry.path, type: assetType});
			}
			this.entries = [for (entry in uniqueEntries.iterator()) entry];
		}
		catch (e)
		{
			trace('Error parsing context file $file: $e');
			this.entries = [];
		}
	}

	public function findAsset(path:String):Bool
	{
		for (entry in entries)
		{
			if (entry.path == path)
			{
				return true;
			}
		}
		return false;
	}
}

/**
 * Represents a single asset entry in a context file.
 * The `type` is a string when parsed from JSON and then converted
 * to `FlxAssetType` in the `AssetContext` constructor.
 */
typedef AssetEntry =
{
	var path:String;
	var type:FlxAssetType;
}
