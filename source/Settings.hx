package;

import flixel.FlxG;

class Settings
{
    private static var timer:haxe.Timer;
    
    public static var preferences:Map<String, Dynamic> = [];

    public static function init() // should save every 1500ms
    {
        FlxG.save.bind('crow-engine', 'eyedalehim');

        if (FlxG.save.data.preferences != null)
            ui.PreferencesMenu.preferences = FlxG.save.data.preferences;
       
        timer = new haxe.Timer(1500);
        timer.run = function()
        {
            preferences = ui.PreferencesMenu.preferences;
            FlxG.save.data.preferences = preferences;
            FlxG.save.flush();
        }
    }
}