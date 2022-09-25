package states.menus;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class MainMenuState extends MusicBeatState
{
	public static var menuList:Array<MenuCallback> = [
		{name: 'story_mode', callback: () -> {}, skipAnimBG: false},
		{name: 'freeplay', callback: function() 
		{
			FlxG.switchState(new FreeplayState());
		}, skipAnimBG: false},
		{
			name: 'donate',
			callback: function()
			{
				FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
			},
			skipAnimBG: true
		},
		{name: 'options', callback: () -> {}, skipAnimBG: false},
	];

	public var menuGroup:FlxTypedGroup<FlxSprite>;
	public var curSelected:Int = 0;

	private var mainBG:FlxSprite;
	private var flickerBG:FlxSprite;
	private var versionText:FlxText;

	private var camFollow:FlxObject;

	override function create()
	{
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		mainBG = new FlxSprite(-80).loadGraphic(Paths.image('menus/mainBG'));
		mainBG.scrollFactor.set(0, 0.20);
		mainBG.scale.set(1.175, 1.175);
		mainBG.updateHitbox();
		mainBG.screenCenter();
		mainBG.antialiasing = Settings.getPref('antialiasing', true);
		add(mainBG);

		flickerBG = new FlxSprite(-80).loadGraphic(Paths.image('menus/flickerBG'));
		flickerBG.scrollFactor.set(0, 0.20);
		flickerBG.scale.set(1.175, 1.175);
		flickerBG.updateHitbox();
		flickerBG.screenCenter();
		flickerBG.visible = false;
		flickerBG.antialiasing = Settings.getPref('antialiasing', true);
		add(flickerBG);

		menuGroup = new FlxTypedGroup<FlxSprite>();
		add(menuGroup);

		versionText = new FlxText(0, 0, 0, "Friday Night Funkin' " + Main.gameVersion.display + " // Crow Engine " + Main.engineVersion.display);
		versionText.scrollFactor.set();
		versionText.antialiasing = Settings.getPref('antialiasing', true);
		versionText.setFormat(Paths.font('vcr.ttf'), 14, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		versionText.updateHitbox();
		versionText.setPosition(4, FlxG.height - versionText.height - 4);
		add(versionText);

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

		changeSelection();
	}

	private var allowControl:Bool = true;

	override function update(elapsed:Float)
	{
		if (allowControl)
		{
			if (FlxG.keys.justPressed.UP)
				changeSelection(-1);
			if (FlxG.keys.justPressed.DOWN)
				changeSelection(1);
			if (FlxG.keys.justPressed.ENTER)
				acceptSelection();
		}

		camFollow.y = Tools.lerpBound(camFollow.y, FlxMath.remapToRange(curSelected, 0, menuList.length - 1, 20, mainBG.x + mainBG.width - 700),
			(elapsed * 3.175));

		super.update(elapsed);
	}

	private function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		curSelected = FlxMath.wrap(curSelected + change, 0, menuList.length);

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
		if (menuList[curSelected].skipAnimBG)
			menuList[curSelected].callback();
		else
		{
			allowControl = false;

			FlxG.sound.play(Paths.sound('menu/confirmMenu'), 0.75);

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
							}
						});
					}
				});
			}
		}
	}
}

typedef MenuCallback =
{
	var name:String;
	var callback:Void->Void;
	var skipAnimBG:Bool;
}