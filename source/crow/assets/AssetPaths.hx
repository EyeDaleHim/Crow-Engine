package crow.assets;

import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;

class AssetPaths 
{
    public static final jsonExt = #if JSON_TO_MESSAGEPACK 'msgp_j' #else 'json' #end;

    public static function from(id:String, type:FlxAssetType):String
    {
        return switch (type)
        {
            case IMAGE: 'assets/textures/$id.png';
            case SOUND: 'assets/sounds/$id.ogg';
            case FONT: 'assets/fonts/vector/$id.ttf';
            case BINARY, TEXT, null: Path.join(['assets', id]);
        }
    }
}