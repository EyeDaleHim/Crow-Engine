package states;

import objects.Alphabet;
import flixel.FlxG;
import flixel.FlxState;

class PlayState extends MusicBeatState
{
	override public function create()
	{
		add(new Alphabet(0, 460, "test", true, false));

		super.create();

		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.5);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
