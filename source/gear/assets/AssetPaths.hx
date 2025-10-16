package gear.assets;

import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;

class AssetPaths 
{
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