package objects;

import flixel.FlxG;
import flixel.FlxSprite;

class Note extends FlxSprite
{
    public var direction:Int = 0;
    public var strumTime:Float = 0;
    public var owner:Owner = NONE;
}

enum abstract Owner(Int)
{
    var PLAYER = 0;
    var ENEMY = 1;
    var NONE = 2;
}