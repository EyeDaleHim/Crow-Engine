package gear.states.internals;

class MainState extends FlxSubState
{
    public var menuMusic:Music;

    public function new()
    {
        super();

        destroySubStates = false;
    }
}