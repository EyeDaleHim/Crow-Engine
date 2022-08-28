package backend;

import flixel.FlxG;

class Settings
{
    public static var prefs:Map<String, Dynamic> = [];

    public static function getPref(name:String, ?defaultPref:Dynamic)
    {
        return !prefs.exists(name) ? defaultPref : prefs.get(name);
    }

    public static function setPref(name:String, value:Dynamic)
    {
        prefs.set(name, value);
        return getPref(name);
    }
}