package backend;

import flixel.FlxG;

class InternalHelper
{
	public static function playSound(sound:SoundEffects, volume:Float = 1)
	{
		FlxG.sound.play(Paths.sound(cast(sound, String)), volume);
	}
}

enum abstract SoundEffects(String)
{
	var CANCEL:SoundEffects = "menu/cancelMenu";
	var SCROLL:SoundEffects = "menu/scrollMenu";
	var CONFIRM:SoundEffects = "menu/confirmMenu";
}
