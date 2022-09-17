package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import states.menus.MainMenuState;

class FreeplayState extends MusicBeatState
{
	public var background:FlxSprite;

	override public function create()
	{
		background = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplayBG"));
		background.scale.set(1.1, 1.1);
		background.screenCenter();
		background.scrollFactor.set();
		background.antialiasing = Settings.getPref('antialiasing', true);
		add(background);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			FlxG.switchState(new MainMenuState());

		super.update(elapsed);
	}
}
