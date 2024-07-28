package objects.notes;

class SustainNote extends FlxSprite
{
    public var wrap:WrapMode = STRETCH;

    override public function new(length:Float = 0.0)
    {
        super();
    }
}

enum WrapMode
{
    STRETCH;
    TILE;
}