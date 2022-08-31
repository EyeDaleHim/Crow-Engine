package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class MainMenuState extends MusicBeatState
{
	public var menuGroup:FlxTypedGroup<FlxSprite>;
	public var curSelected:Int = 0;
}