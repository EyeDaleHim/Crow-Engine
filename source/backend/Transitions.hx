package backend;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;

class Transitions
{
	public static function transition(duration:Float, fade:Easing, type:TransitionType, callbacks:Callbacks)
	{
		if (duration == null)
            duration = 1.0;
        if (fade == null)
            throw "backend.Transitions.transition()'s fade attribute cannot be null.";
        
        var camera:FlxCamera = new FlxCamera();
		FlxG.cameras.add(camera);

		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		group.cameras = [camera];
		FlxG.state.add(group);

		switch (type)
		{
			case Fade:
				{
                    var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
                    black.alpha = (fade == In ? 0.0 : 1.0);
                    group.add(black);

                    FlxTween.tween(black, {alpha: (fade == In ? 1.0 : 0.0)}, duration, {ease: FlxEase.quadOut});
                }
			default: // null
				{
                    if (callbacks.startCallback != null)
                        callbacks.startCallback();
                    if (callbacks.endCallback != null)
                        callbacks.endCallback();
                }
		}
	}
}

typedef Callbacks =
{
	var startCallback:Void->Void;
	var updateCallback:Void->Void;
	var endCallback:Void->Void;
}

enum TransitionType
{
	Fade;
	Slider_Down;
	Slider_Up;
	Slider_Left;
	Slider_Right;
	Pixel_Fade;
	Pixel_Slider_Down;
	Pixel_Slider_Up;
	Pixel_Slider_Right;
	Pixel_Slider_Left;
}

enum Easing
{
	In;
	Out;
}
