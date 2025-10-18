package gear.assets.paths;

import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;

typedef PathDirectoryStruct = {
    var ?recursive:Bool;
    var ?type:FlxAssetType;
    var paths:Array<String>;
};