package states.menus;

class FreeplayState extends MainState
{
    public var background:FlxSprite;

    public var alphabetTest:Alphabet;

    override function create()
    {
        background = new FlxSprite(Assets.image('menus/freeplayBG'));
		background.active = false;
		add(background);

        alphabetTest = new Alphabet(100, 100, "testing1234567890");
        add(alphabetTest);

        super.create();
    }
}