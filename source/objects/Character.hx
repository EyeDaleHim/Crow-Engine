package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxAtlasFrames;

class Character extends FlxSprite
{
    // basic info
    public var name:String;
    public var isPlayer:Bool;

    // animation stuff
    public var animOffsets:Map<String, FlxPoint> = [];
    public var idleList:Array<String> = [];

    // handled by this class
    private var _idleIndex:Int = 0;

    public function new(x:Float, y:Float, name:String, isPlayer:Bool)
    {
        super(x, y);

        this.name = name;
        this.isPlayer = isPlayer;
    }

    override function destroy()
    {
        super.destroy();

        animOffsets = null;
        idleList = null;
    }
}