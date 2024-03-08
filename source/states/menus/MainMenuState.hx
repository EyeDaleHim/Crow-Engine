package states.menus;

class MainMenuState extends MainState
{
    public static var itemList:Array<String> = ["story", "freeplay", "options", "donate"];

    public var background:FlxSprite;
    public var flicker:FlxSprite;

    public var menuItems:FlxTypedGroup<FlxSprite>;

    public var selected:Int = 0;

    public var followLerp:FlxPoint = FlxPoint.get();

    override function create()
    {
        super.create();

        musicHandler.safePlayInst("freakyMenu", 0.8);

        background = new FlxSprite(Assets.image('menus/mainBG'));
        background.scrollFactor.y = 0.20;
        background.active = false;
        background.scale.set(1.175, 1.175);
        background.updateHitbox();
        background.screenCenter();
        add(background);

        flicker = new FlxSprite(Assets.image('menus/flickerBG'));
        flicker.scrollFactor.y = 0.20;
        flicker.active = false;
        flicker.scale.set(1.175, 1.175);
        flicker.updateHitbox();
        background.screenCenter();
        flicker.kill();
        add(flicker);

        menuItems = new FlxTypedGroup<FlxSprite>();
        add(menuItems);

        for (item in itemList)
        {
            var i:Int = itemList.indexOf(item);

            var sprItem:FlxSprite = new FlxSprite(0, 50 + (i * 170));
			sprItem.frames = Assets.frames('menus/mainmenu/menu_' + itemList[i]);
			sprItem.animation.addByPrefix('idle', itemList[i] + " basic", 24);
			sprItem.animation.addByPrefix('selected', itemList[i] + " white", 24);
			sprItem.animation.play('idle');
			sprItem.ID = i;
			sprItem.scrollFactor.set();
			sprItem.screenCenter(X);
			sprItem.updateHitbox();
			menuItems.add(sprItem);
        }

        selectItem();
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.anyJustPressed([W, UP]))
            selectItem(-1);
        if (FlxG.keys.anyJustPressed([S, DOWN]))
            selectItem(1);

        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, followLerp.y, FlxMath.bound(elapsed * 3.175, 0, 1));

        super.update(elapsed);
    }

    public function selectItem(change:Int = 0)
    {
        selected = FlxMath.wrap(selected + change, 0, itemList.length - 1);

        if (change != 0)
            FlxG.sound.play(Assets.sound("menu/scrollMenu", SFX), 0.5);

        menuItems.forEach(function(spr:FlxSprite)
        {
            if (spr.ID == selected)
                spr.animation.play("selected");
            else
                spr.animation.play("idle");

            spr.updateHitbox();
            spr.screenCenter(X);
        });

        followLerp.y = selected * 100;
    }
}