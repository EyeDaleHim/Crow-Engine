package gear.assets;

import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;

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

        entries = Json.parse(FlxG.assets.getTextUnsafe(Path.join([contextDirectory, '$file.json'])));
    }

    public function findAsset(fullPath:String):Bool
    {
        for (entry in entries)
        {
            for (file in entry.files)
            {
                if (file == fullPath)
                {
                    return true;
                }
            }
        }
        return false;
    }
}

typedef AssetContextFile = Array<AssetContextEntry>;

typedef AssetContextEntry = {
    var type:FlxAssetType;
    var files:Array<String>;
};
