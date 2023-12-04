package states.menus;

import flixel.effects.FlxFlicker;
import mods.ModManager;

class MainMenuState extends MusicBeatState
{
	public static var menuList:Array<MenuCallback> = [
		{
			name: 'story_mode',
			callback: function()
			{
				MusicBeatState.switchState(new StoryMenuState());
			},
			skipAnimBG: false
		},
		{
			name: 'freeplay',
			callback: function()
			{
				MusicBeatState.switchState(new FreeplayState());
			},
			skipAnimBG: false
		},
		{
			name: 'donate',
			callback: function()
			{
				FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
			},
			skipAnimBG: true
		},
		{
			name: 'options',
			callback: function()
			{
				MusicBeatState.switchState(new states.options.OptionsMenu());
			},
			skipAnimBG: false
		},
	];

	public var menuGroup:FlxTypedGroup<FlxSprite>;
	public var curSelected:Int = 0;

	private var mainBG:FlxSprite;
	private var flickerBG:FlxSprite;

	private var versionText:FlxText;
	private var modText:FlxText;

	private var camFollow:FlxObject;

	override function create()
	{
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		mainBG = new FlxSprite(-80, Paths.image('menus/mainBG'));
		mainBG.scrollFactor.set(0, 0.20);
		mainBG.scale.set(1.175, 1.175);
		mainBG.updateHitbox();
		mainBG.screenCenter();
		mainBG.antialiasing = Settings.getPref('antialiasing', true);
		mainBG.active = false;
		add(mainBG);

		flickerBG = new FlxSprite(-80, Paths.image('menus/flickerBG'));
		flickerBG.scrollFactor.set(0, 0.20);
		flickerBG.scale.set(1.175, 1.175);
		flickerBG.updateHitbox();
		flickerBG.screenCenter();
		flickerBG.visible = false;
		flickerBG.antialiasing = Settings.getPref('antialiasing', true);
		flickerBG.active = false;
		add(flickerBG);

		menuGroup = new FlxTypedGroup<FlxSprite>();
		add(menuGroup);

		versionText = new FlxText(0, 0, 0, "Friday Night Funkin' " + Main.gameVersion.display + " // Crow Engine " + Main.engineVersion.display);
		versionText.scrollFactor.set();
		versionText.antialiasing = Settings.getPref('antialiasing', true);
		versionText.setFormat(Paths.font('vcr.ttf'), 14, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		versionText.updateHitbox();
		versionText.setPosition(4, FlxG.height - versionText.height - 4);
		versionText.active = false;
		add(versionText);

		modText = new FlxText(0, 0, 0, ModManager.mods.length == 1 ? "1 Mod Active" : ModManager.mods.length + "Mods Active");
		modText.scrollFactor.set();
		modText.antialiasing = Settings.getPref('antialiasing', true);
		modText.setFormat(Paths.font('vcr.ttf'), 16, 0xFFFFFFFF, RIGHT, OUTLINE, 0xFF000000);
		modText.updateHitbox();
		modText.setPosition(FlxG.width - modText.width - 4, FlxG.height - modText.height - 4);
		modText.active = false;
		add(modText);

		for (item in menuList)
		{
			var i:Int = menuList.indexOf(item);

			var sprItem:FlxSprite = new FlxSprite(0, 50 + (i * 170));
			sprItem.frames = Paths.getSparrowAtlas('menus/mainmenu/menu_' + menuList[i].name);
			sprItem.animation.addByPrefix('idle', menuList[i].name + " basic", 24);
			sprItem.animation.addByPrefix('selected', menuList[i].name + " white", 24);
			sprItem.animation.play('idle');
			sprItem.ID = i;
			sprItem.scrollFactor.set();
			sprItem.screenCenter(X);
			sprItem.updateHitbox();
			sprItem.antialiasing = Settings.getPref('antialiasing', true);
			menuGroup.add(sprItem);
		}

		FlxG.camera.follow(camFollow, null, 1);

		super.create();

		InputHandler.registerControl('BACK', function()
		{
			MusicBeatState.switchState(new TitleState());
		});

		InputHandler.registerControl('UI_UP', function()
		{
			changeSelection(-1);
		});

		InputHandler.registerControl('UI_DOWN', function()
		{
			changeSelection(1);
		});

		InputHandler.registerControl('ACCEPT', acceptSelection);

		InputHandler.registerControl(FlxKey.SEVEN, function()
		{
			openSubState(new states.debug.EditorSelectionState());
		});

		changeSelection();
	}

	private var allowControl:Bool = true;

	override function update(elapsed:Float)
	{
		camFollow.y = Tools.lerpBound(camFollow.y, FlxMath.remapToRange(curSelected, 0, menuList.length - 1, 20, mainBG.x + mainBG.width - 700),
			(elapsed * 3.175));

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0)
	{
		InternalHelper.playSound(SCROLL, 0.75);

		curSelected = FlxMath.wrap(curSelected + change, 0, menuList.length - 1);

		menuGroup.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
				spr.animation.play('selected');
			else
				spr.animation.play('idle');

			spr.updateHitbox();
			spr.centerOrigin();

			spr.screenCenter(X);
		});
	}

	private function acceptSelection()
	{
		if (menuList[curSelected] == null)
		{
			trace('Unknown selection: $curSelected'); // for scripts shit
			return;
		}

		if (menuList[curSelected].skipAnimBG)
			menuList[curSelected].callback();
		else
		{
			allowControl = false;

			InternalHelper.playSound(CONFIRM, 0.75);

			menuGroup.forEach(function(spr:FlxSprite)
			{
				if (spr.ID != curSelected)
					FlxTween.tween(spr, {alpha: 0.0}, 0.5, {ease: FlxEase.quadOut});
				else
				{
					FlxFlicker.flicker(spr, 1.1, 0.06);
				}
			});

			if (Settings.getPref('flashing-lights', true))
			{
				FlxFlicker.flicker(flickerBG, 1.1, 0.15, true, true, function(_)
				{
					if (menuList[curSelected].callback != null)
						menuList[curSelected].callback();
					else
						revertBack();
				});
			}
			else
			{
				flickerBG.visible = true;
				FlxTween.tween(flickerBG, {alpha: 1.0}, 0.2, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(flickerBG, {alpha: 0.0}, 0.9, {
							ease: FlxEase.quadIn,
							onComplete: function(twn:FlxTween)
							{
								if (menuList[curSelected].callback != null)
									menuList[curSelected].callback();
								else
									revertBack();
							}
						});
					}
				});
			}
		}
	}

	private function revertBack():Void
	{
		flickerBG.visible = false;
		allowControl = true;
	}
}

typedef MenuCallback =
{
	var name:String;
	var callback:Void->Void;
	var skipAnimBG:Bool;
}
