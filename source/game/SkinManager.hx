package game;

import haxe.Json;
import openfl.Assets;

class SkinManager
{
    public static var comboSkin:ComboSkin;
    public static var countdownSkin:CountdownSkin;

    public static function parseComboSkin(skin:String):ComboSkin
    {
        var skin:ComboSkin = Json.parse(Assets.getText(Paths.imagePath('game/combo/$skin/combo').replace('.png', '.json')));

        if (skin.scale == null)
            skin.scale = {x: 1.0, y: 1.0};
        if (skin.forcedAntialias == null)
            skin.forcedAntialias = true;
        if (skin.useActualScale == null)
            skin.useActualScale = false;

        SkinManager.comboSkin = skin;

        return skin;
    }

    public static function parseCountdownSkin(skin:String):CountdownSkin
        {
            var skin:ComboSkin = Json.parse(Assets.getText(Paths.imagePath('game/countdown/$skin/countdown').replace('.png', '.json')));

            if (skin.scale == null)
                skin.scale = {x: 1.0, y: 1.0};
            if (skin.forcedAntialias == null)
                skin.forcedAntialias = true;

            SkinManager.countdownSkin = skin;
    
            return skin;
        }
}

// only doing this if i want to add something in future updates
typedef ComboSkin = 
{
    var scale:{x:Float, y:Float};
    var forcedAntialias:Null<Bool>;
    var useActualScale:Null<Bool>;
}

typedef CountdownSkin =
{
    var scale:{x:Float, y:Float};
    var forcedAntialias:Null<Bool>;
}
