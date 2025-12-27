package crow.assets;

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

	/**
	 * The flag that indicates whether any context has been unloaded, which means 
	 * that the cache needs to be checked for orphaned assets.
	 */
	public static var dirtyContexts:Bool = false;

	/**
	 * If true, all assets will be required to have an associated asset context, they will not
	 * load otherwise.
	 */
	public static var enforceAssetContext:Bool = false;

	public var name(default, null):String;
	public var entries(default, null):Array<AssetEntry>;

	public function new(file:String)
	{
		this.name = file;

		try
		{
			var parsedEntries:Array<AssetEntry> = cast Main.assets.json(Path.join([contextDirectory, file]));
			if (parsedEntries == null)
			{
				this.entries = [];
				return;
			}
			final uniqueEntries = new Map<String, AssetEntry>();
			for (entry in parsedEntries)
			{
				// The `type` from JSON is a string, we need to convert it to FlxAssetType enum
				final rawType:String = cast(entry.type, String).toLowerCase().trim();
				if (rawType == "spritesheet")
				{
					#if !SBS_SPARROW
					// We aren't using SBS, convert this spritesheet entry to .png and .xml
					uniqueEntries.set(entry.path, {path: entry.path, type: IMAGE});
					final xmlPath = Path.join(['textures', Path.withExtension(entry.path, 'xml')]);
					uniqueEntries.set(xmlPath, {path: xmlPath, type: TEXT});
					#else
					final sbsPath = Path.join(['textures', Path.withExtension(entry.path, 'sbs')]);
					uniqueEntries.set(sbsPath, {path: sbsPath, type: BINARY});
					#end
						continue;
				}
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

	public static function removeDuplicates(context:AssetContext):AssetContext
	{
		if (context == null)
		{
			return null;
		}

		final uniqueEntries = new Map<String, AssetEntry>();
		for (entry in context.entries)
		{
			uniqueEntries.set(entry.path, entry);
		}
		context.entries = [for (entry in uniqueEntries.iterator()) entry];
		return context;
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
