package states.menus;

class MainMenuState extends MainState
{
    public var background:FlxSprite;

    override function create()
    {
        super.create();

        musicHandler.safePlayInst("freakyMenu", 0.8);

        background = new FlxSprite(Assets.image('menus/mainBG'));
        background.active = false;
        background.scale.set(1.1, 1.1);
        background.updateHitbox();
        add(background);
    }
}