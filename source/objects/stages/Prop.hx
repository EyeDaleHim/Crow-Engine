package objects.stages;

class Prop extends FlxSprite
{
    public var name:String = '';
    // public var attachedScripts:Array<Script> = [];

    public function new(?x:Float = 0.0, ?y:Float = 0.0, name:String = "")
    {
        super(x, y);

        this.name = name;
    }

    public function beatHit()
    {
        
    }
}