package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import objects.Alphabet;
import states.options.OptionsMenu;
import utils.InputFormat;

class ControlsBindSubState extends MusicBeatSubState
{
	private var backTime:Float = 0.0;
	private var bind:String;
	private var keyIndex:Int = 0;

	override public function new(bind:String, keyIndex:Int)
	{
		super();

		this.bind = bind;
		this.keyIndex = keyIndex;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.getKey('BACK', JUST_PRESSED))
		{
			backTime += 2.5 / 2.75;
		}
		else if (backTime <= 0.0
			&& controls.getKey('BACK', PRESSED)
			|| InputFormat.matchesInput(FlxG.keys.firstJustReleased())) // released in case i want combination binding later
		{
			var savedBinding:Array<Int> = Settings.grabKey(bind);
			savedBinding[keyIndex] = FlxG.keys.firstJustReleased();

			Settings.changeKey(bind, savedBinding);

			FlxG.sound.play(Paths.sound("menus/cancelMenu"));
			close();
		}

		backTime -= elapsed * 6;
		backTime = Math.max(0, backTime);
	}
}
