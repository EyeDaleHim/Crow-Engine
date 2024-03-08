package states;

class MainState extends FlxState
{
    public var musicHandler:Music;

    override function create()
    {
        musicHandler = new Music();
    }
}