package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import states.menus.MainMenuState;

class FreeplayState extends MusicBeatState
{
	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			FlxG.switchState(new MainMenuState());

		super.update(elapsed);
	}
}
