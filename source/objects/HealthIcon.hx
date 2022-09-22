package objects;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
    public var char:String;

    override function new(x:Float = 0, y:Float = 0, char:String = 'bf')
    {
        super(x, y);

        // note to self: separate them in a later update
    }
}