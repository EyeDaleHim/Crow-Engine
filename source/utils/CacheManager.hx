package utils;

import flixel.FlxG;
import flixel.FlxSprite;

class CacheManager
{
	// also they get cached immediately when the game starts, no need to load them when they get used
	// first time
	public static var persistentAssets:Array<String> = ['alphabet', 'mainBG', 'freeplayBG', 'flickerBG'];
}
