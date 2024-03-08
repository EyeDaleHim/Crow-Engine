package states.menus;

class FreeplayState extends MainState
{
    public var background:FlxSprite;

    override function create()
    {
        background = new FlxSprite(Assets.image('menus/freeplayBG'));
		background.active = false;
		add(background);

        super.create();
    }
}