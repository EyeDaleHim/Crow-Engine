package objects;

class FNFSprite extends FlxSprite
{
    public var autoMoves:Bool = true;

    override public function update(elapsed:Float)
    {
        if (autoMoves)
            moves = (velocity.x != 0 || velocity.y != 0);
        super.update(elapsed);
    }

    public static function readAnimationFile(sprite:FNFSprite, animationFile:Animation):FNFSprite
    {
        if (animationFile != null)
        {

        }

        return sprite;
    }
}