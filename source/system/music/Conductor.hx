package system.music;

class Conductor extends FlxBasic
{
    public static var list:Array<Conductor> = [];

    public var attachedSound:FlxSound;

    public var beat:Float = 0.0;
    public var step:Float = 0.0;
    public var section:Float = 0.0;

    public function getBeat():Int
    {}

    public function getStep():Int
    {}

    public function getSection():Int
    {}
}