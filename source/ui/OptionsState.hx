package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import haxe.ds.EnumValueMap;

class OptionsState extends MusicBeatState
{
	public static var fromPlayState:Bool = false;
	public var pages:EnumValueMap<PageName, Page> = new EnumValueMap();
	public var currentName:PageName = Options;
	public var currentPage(get, never):Page;

	inline function get_currentPage()
		return pages.get(currentName);

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFEA71FD;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);
		var optionsMenu:OptionsMenu = addPage(Options, new OptionsMenu(false));
		var preferencesMenu:PreferencesMenu = addPage(Preferences, new PreferencesMenu());
		var controlsMenu:ControlsMenu = addPage(Controls, new ControlsMenu());
		var categoryMenu:PreferencesCategory = addPage(Category, new PreferencesCategory());
		if (optionsMenu.hasMultipleOptions())
		{
			optionsMenu.onExit.add(exitToMainMenu);
			controlsMenu.onExit.add(function()
			{
				switchPage(Options);
			});
			preferencesMenu.onExit.add(function()
			{
				switchPage(Options);
			});
		}
		else
		{
			controlsMenu.onExit.add(exitToMainMenu);
			setPage(Controls);
		}
		currentPage.enabled = false;
		super.create();
	}

	function addPage(name:PageName, page:Page):Dynamic
	{
		page.onSwitch.add(switchPage);
		pages.set(name, page);
		add(page);
		page.exists = name == currentName;
		return page;
	}

	function setPage(name:PageName)
	{
		if (pages.exists(currentName))
		{
			currentPage.exists = false;
		}
		currentName = name;
		if (pages.exists(currentName))
		{
			currentPage.exists = true;
		}
	}

	override function finishTransIn()
	{
		super.finishTransIn();
		currentPage.enabled = true;
	}

	function switchPage(name:PageName)
	{
		setPage(name);
	}

	function exitToMainMenu()
	{
		currentPage.enabled = false;
		if (fromPlayState)
			FlxG.switchState(new PlayState());
		else
			FlxG.switchState(new MainMenuState());
		fromPlayState = false;
	}
}