package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import objects.Alphabet;
import states.options.OptionsMenu;
import utils.InputFormat;

class ControlsBindSubState extends MusicBeatSubState
{
	private var backTime:Float = 0.0;
	private var bind:String;
	private var keyIndex:Int = 0;

	public var background:FlxSprite;

	override public function new(bind:String, keyIndex:Int)
	{
		super();

		this.bind = bind;
		this.keyIndex = keyIndex;

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0;
		add(background);

		FlxTween.tween(background, {alpha: 0.6}, 1);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		close(); // will add functionality later
	}
}
