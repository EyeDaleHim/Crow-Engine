package substates;

class PauseSubState extends MainSubState
{
	public var itemList:Array<String> = ["Resume", "Restart Song", "Exit to Menu"];

	public var menuItems:FlxTypedGroup<Alphabet>;

    public var songNameText:FlxText;
    public var diffNameText:FlxText;
    public var deathCountText:FlxText;

	public var selected:Int = 0;

    public var actions:Array<ActionDigital> = [];

	public function new(camera:FlxCamera)
	{
		super();

		persistentUpdate = false;

		this.camera = camera;

		menuItems = new FlxTypedGroup<Alphabet>();
		add(menuItems);

		var index:Int = 0;
		for (item in itemList)
		{
			var item:Alphabet = new Alphabet(20 * (1 + index), 60 * (1 + index), item);
			item.ID = index;
			item.alpha = 0.6;
			item.antialiasing = true;

			menuItems.add(item);

			index++;
		}

		openCallback = function()
		{
			camera.bgColor.alphaFloat = 0.0;
			camera.visible = true;

			for (i in 0...menuItems.members.length)
				menuItems.members[i].setPosition(20 * (1 + i), 60 * (1 + i));

            for (action in actions)
            {
                action.active = true;
            }
		};

        actions.push(Controls.registerFunction(Control.UI_UP, JUST_PRESSED, changeItem.bind(-1)));
        actions.push(Controls.registerFunction(Control.UI_DOWN, JUST_PRESSED, changeItem.bind(1)));
        actions.push(Controls.registerFunction(Control.ACCEPT, JUST_PRESSED, acceptItem));

        changeItem();
	}

	private var _songRestarted:Bool = false;

	override public function update(elapsed:Float)
	{
		camera.bgColor.alphaFloat = Math.min(camera.bgColor.alphaFloat + elapsed, 0.6);

		menuItems.forEach(function(text:Alphabet)
		{
			var textPos:FlxPoint = FlxPoint.get();

			textPos.x = 90 + (35 * (text.ID - selected));

			var center:Float = (FlxG.height / 2) - (text.height / 2);

			textPos.y = center + (165 * (text.ID - selected));

			text.x = FlxMath.lerp(text.x, textPos.x, FlxMath.bound(elapsed * 7, 0, 1));
			text.y = FlxMath.lerp(text.y, textPos.y, FlxMath.bound(elapsed * 7, 0, 1));
		});

		super.update(elapsed);
	}

	public function changeItem(change:Int = 0)
	{
		if (menuItems.members[selected] != null)
			menuItems.members[selected].alpha = 0.6;

		selected = FlxMath.wrap(selected + change, 0, menuItems.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sfx("menu/scrollMenu"), 0.5);

		if (menuItems.members[selected] != null)
			menuItems.members[selected].alpha = 1.0;
	}

    public function acceptItem()
    {
        switch (itemList[selected])
        {
            case "Resume":
            {
                close();
            }
            case "Restart Song":
            {
				_songRestarted = true;
                close();
				PlayState.instance.restartSong();
            }
			case "Exit to Menu":
			{
				closeCallback = null;
				close();
				
				if (PlayState.instance.isStory)
					FlxG.switchState(() -> new states.menus.MainMenuState());
				else
					FlxG.switchState(() -> new states.menus.FreeplayState());
			}
        }
    }
}
