package ui;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

class PreferencesMenu extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	var descriptionTxt:FlxText;
	var descriptionBG:FlxSprite;

	override public function new()
	{
		super();

		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;

		add(items = new TextMenuList());
		createPrefItem('naughtyness', 'censor-naughty', 'Censor inappropriate words', true);
		createPrefItem('downscroll', 'downscroll', 'Which direction the notes should go from', false);
		createPrefItem('ghost tap', 'ghost-tap', 'Give the player a miss penalty for tapping with no hittable notes', false);
		createPrefItem('flashing lights', 'flashing-lights', 'Prevent flashing lights for photosensitive players', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', 'If the camera should zoom based on the beat', true);
		createPrefItem('Performance Counter', 'fps-counter', 'Should the FPS Counter be visible', true);
		createPrefItem('Auto Pause', 'auto-pause', 'If the game should pause when you focus out of it', false);

		descriptionTxt = new FlxText(0, FlxG.height * 0.85, 0, "", 32);
		descriptionTxt.setFormat(Paths.defaultFont, 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		descriptionTxt.scrollFactor.set();
		descriptionTxt.text = items.members[items.selectedIndex].description;

		descriptionBG = new FlxSprite(0, FlxG.height * 0.85).makeGraphic(Math.floor(descriptionTxt.width + 8), Math.floor(descriptionTxt.height + 8), 0xFF000000);
		descriptionBG.alpha = 0.4;
		descriptionBG.scrollFactor.set();
		descriptionBG.y = descriptionTxt.y - 4;
		descriptionBG.screenCenter(X);
		add(descriptionBG);
		add(descriptionTxt);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
		menuCamera.maxScrollY = items.members[items.length - 1].y + items.members[items.length - 1].height + 16;
	}

	public static function getPref(pref:String)
	{
		return preferences.get(pref);
	}

	public static function initPrefs()
	{
		preferenceCheck('censor-naughty', true);
		preferenceCheck('downscroll', false);
		preferenceCheck('ghost-tap', false);
		preferenceCheck('flashing-lights', true);
		preferenceCheck('camera-zoom', true);
		preferenceCheck('fps-counter', true);
		preferenceCheck('auto-pause', false);
		preferenceCheck('master-volume', 1);
		if (!getPref('fps-counter'))
		{
			Lib.current.stage.removeChild(Main.fpsCounter);
		}
		FlxG.autoPause = getPref('auto-pause');
		Settings.init();
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + Std.string(preferences.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, description:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		items.members[items.length - 1].description = description;
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;
		trace('toggled? ' + Std.string(preferences.get(identifier)));
		switch (identifier)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
			case 'fps-counter':
				if (getPref('fps-counter'))
					Lib.current.stage.addChild(Main.fpsCounter);
				else
					Lib.current.stage.removeChild(Main.fpsCounter);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.05, FlxG.updateFramerate);
		items.forEach(function(item:MenuItem)
		{
			if (item == items.members[items.selectedIndex])
				item.x = 150;
			else
				item.x = 120;
		});
		changeDescTxt(items.members[items.selectedIndex].description);
		descriptionTxt.screenCenter(X);

		descriptionBG.setPosition(
			CoolUtil.coolLerp(descriptionBG.x, descriptionTxt.x - 16, 0.50), 
			CoolUtil.coolLerp(descriptionBG.y, descriptionTxt.y - 4, 0.50)
		);
		descriptionBG.setGraphicSize(
			Math.floor(CoolUtil.coolLerp(descriptionBG.width, descriptionTxt.width + 32, 0.40)), 
			Math.floor(CoolUtil.coolLerp(descriptionBG.height, descriptionTxt.height + 8, 0.40))
		);
		descriptionBG.updateHitbox();

		descriptionTxt.clipRect = new flixel.math.FlxRect(0, 0, descriptionBG.width, descriptionBG.height);
	}

	function changeDescTxt(text:String)
	{
		descriptionTxt.fieldWidth = 0;
		descriptionTxt.text = text;
		descriptionTxt.fieldWidth = descriptionTxt.width;
		descriptionTxt.updateHitbox();
	}
}