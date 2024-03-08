package states.menus;

class MainMenuState extends FlxState
{
    override function create()
    {
        super.create();

        var testSpr:FlxSprite = new FlxSprite(Assets.image('alphabet'));
        add(testSpr);
    }
}