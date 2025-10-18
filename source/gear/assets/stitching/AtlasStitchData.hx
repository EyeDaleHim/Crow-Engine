package gear.assets.stitching;

import gear.assets.paths.PathDirectoryStruct;

typedef AtlasStitchData = {
    var name:String;
    var ?images:Array<String>;
    var ?directories:Array<PathDirectoryStruct>;
};