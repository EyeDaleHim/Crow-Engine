package;

import flixel.FlxG;
import lime.app.Application;

class Settings
{
    private static var timer:haxe.Timer;
    
    public static var preferences:Map<String, Dynamic> = [];

    public static function init()
    {
        FlxG.save.bind('crow-engine', 'eyedalehim');

        if (FlxG.save.data.preferences != null)
            ui.PreferencesMenu.preferences = FlxG.save.data.preferences;

        Application.current.onExit.add(function(v:Int)
        {
            save();
        });
       
        timer = new haxe.Timer(60000); // in case something goes wrong
        timer.run = save;
    }

    public static function save():Void
    {
        preferences = ui.PreferencesMenu.preferences;
        FlxG.save.data.preferences = preferences;
        FlxG.save.flush();
    }
}