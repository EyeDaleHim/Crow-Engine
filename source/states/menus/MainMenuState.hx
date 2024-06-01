package states.menus;

class MainMenuState extends MainState
{
	public static var itemList:Array<String> = ["story", "freeplay", "options", "donate"];

	public var background:FlxSprite;
	public var flicker:FlxSprite;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	public var selectedItem:Int = 0;
	public var selected:Bool = false;

	public var followLerp:FlxPoint = FlxPoint.get();

	override function create()
	{
		super.create();

		MainState.musicHandler.playInst("menus/freakyMenu", 0.8);
		MainState.conductor.sound = MainState.musicHandler.inst;

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
		flicker.screenCenter();
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

		add(new Stepper(20, 70, {cornerSize: 8.0}));

		changeItem();
	}

	override public function update(elapsed:Float)
	{
		if (!selected)
		{
			if (FlxG.keys.anyJustPressed([W, UP]))
				changeItem(-1);
			if (FlxG.keys.anyJustPressed([S, DOWN]))
				changeItem(1);
			if (FlxG.keys.justPressed.ENTER)
				selectItem();
		}
		else
		{
			menuItems.forEach(function(spr:FlxSprite)
			{
				if (spr.ID != selectedItem)
				{
					spr.alpha -= elapsed * 3;
				}
			});
		}

		FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, followLerp.y, FlxMath.bound(elapsed * 3.175, 0, 1));

		super.update(elapsed);
	}

	public function selectItem()
	{
		flicker.revive();
		FlxFlicker.flicker(flicker, 1.0, 0.15);
		FlxFlicker.flicker(menuItems.members[selectedItem], 1.0, 0.06);

		FlxG.sound.play(Assets.sfx("menu/confirmMenu"), 0.7);

		FlxTimer.wait(1.0, function()
		{
			switch (itemList[selectedItem])
			{
				case "freeplay":
					{
						FlxG.switchState(states.menus.FreeplayState.new);
					}
				case "options":
				{
					FlxG.switchState(states.options.OptionsState.new);
				}
				default:
					{
						// do something...
						flicker.kill();
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (spr.ID != selectedItem)
								spr.alpha = 1.0;
						});

						selected = false;
					}
			}
		});

		selected = true;
	}

	public function changeItem(change:Int = 0)
	{
		selectedItem = FlxMath.wrap(selectedItem + change, 0, itemList.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sfx("menu/scrollMenu"), 0.5);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == selectedItem)
				spr.animation.play("selected");
			else
				spr.animation.play("idle");

			spr.updateHitbox();
			spr.screenCenter(X);
		});

		followLerp.y = selectedItem * 100;
	}
}
