package backend;

import flixel.util.FlxGradient;
import flixel.tweens.FlxEase.EaseFunction;

using StringTools;

class Transitions
{
	public static var transIn:Bool = true;
	public static var transOut:Bool = true;

	public static function transition(duration:Null<Float>, fade:Easing, ease:Null<EaseFunction>, type:TransitionType, callbacks:Callbacks)
	{
		duration = duration ?? 0.5;

		if (fade == null)
			throw "Transition \"Easing\" parameter cannot be null.";

		ease = ease ?? FlxEase.quadOut;

		var camera:FlxCamera = new FlxCamera();
		camera.bgColor = 0;
		FlxG.cameras.add(camera, false);

		if ((!transIn && fade == In) || (!transOut && fade == Out))
			type = None;

		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		group.cameras = [camera];
		group.active = false;
		FlxG.state.add(group);

		switch (type)
		{
			case Fade:
				{
					var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
					black.alpha = (fade == In ? 0.0 : 1.0);
					group.add(black);

					FlxTween.tween(black, {alpha: (fade == In ? 1.0 : 0.0)}, duration, {
						ease: ease,
						onStart: function(twn:FlxTween)
						{
							if (callbacks.startCallback != null)
								callbacks.startCallback();
						},
						onUpdate: function(twn:FlxTween)
						{
							if (callbacks.updateCallback != null)
								callbacks.updateCallback();
						},
						onComplete: function(twn:FlxTween)
						{
							if (callbacks.endCallback != null)
								callbacks.endCallback();
						}
					});
				}
			case Slider_Up:
				{
					var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 200, [FlxColor.BLACK, 0x0]);
					gradient.flipY = (fade == In);
					group.add(gradient);

					var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height * 1.2), FlxColor.BLACK);
					group.add(black);

					gradient.y = FlxG.height;
					black.y = (gradient.y + gradient.height) - 50;

					FlxTween.tween(gradient, {y: -gradient.height - 50}, duration, {
						ease: ease,
						onStart: function(twn:FlxTween)
						{
							if (callbacks.startCallback != null)
								callbacks.startCallback();
						},
						onUpdate: function(twn:FlxTween)
						{
							if (callbacks.updateCallback != null)
								callbacks.updateCallback();

							if (fade == Out)
								black.y = gradient.y - black.height;
							else
								black.y = (gradient.y + gradient.height) - 50;
						},
						onComplete: function(twn:FlxTween)
						{
							if (callbacks.endCallback != null)
								callbacks.endCallback();
						}
					});
				}
			case Slider_Down:
				{
					var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(FlxG.width, 200, [FlxColor.BLACK, 0x0]);
					gradient.flipY = (fade == Out);
					group.add(gradient);

					var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height * 1.2), FlxColor.BLACK);
					group.add(black);

					gradient.y = -gradient.height;
					black.y = (gradient.y - black.height) + 50;

					FlxTween.tween(gradient, {y: FlxG.height}, duration, {
						ease: ease,
						onStart: function(twn:FlxTween)
						{
							if (callbacks.startCallback != null)
								callbacks.startCallback();
						},
						onUpdate: function(twn:FlxTween)
						{
							if (callbacks.updateCallback != null)
								callbacks.updateCallback();

							if (fade == In)
								black.y = (gradient.y - black.height) + 50;
							else
								black.y = gradient.y + gradient.height;
						},
						onComplete: function(twn:FlxTween)
						{
							if (callbacks.endCallback != null)
								callbacks.endCallback();
						}
					});
				}
			case Slider_Right:
				{
					var gradient:FlxSprite = FlxGradient.createGradientFlxSprite(200, FlxG.height, [FlxColor.BLACK, 0x0], 1, 0);
					gradient.flipX = (fade == Out);
					group.add(gradient);

					var black:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 1.2), FlxG.height, FlxColor.BLACK);
					group.add(black);

					gradient.x = gradient.width;
					black.x = (gradient.y + gradient.height) - 50;

					FlxTween.tween(gradient, {x: FlxG.width}, duration, {
						ease: ease,
						onStart: function(twn:FlxTween)
						{
							if (callbacks.startCallback != null)
								callbacks.startCallback();
						},
						onUpdate: function(twn:FlxTween)
						{
							if (callbacks.updateCallback != null)
								callbacks.updateCallback();

							if (fade == In)
								black.x = (gradient.x - black.width) + 50;
							else
								black.x = gradient.x + gradient.width;
						},
						onComplete: function(twn:FlxTween)
						{
							if (callbacks.endCallback != null)
								callbacks.endCallback();
						}
					});
				}
			case Pixel_Fade:
				{
					var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
					black.alpha = (fade == In ? 0.0 : 1.0);
					group.add(black);

					// dumbest way to make use of callbacks
					FlxTween.num(0, 1, duration, {
						onStart: function(twn:FlxTween)
						{
							if (callbacks.startCallback != null)
								callbacks.startCallback();
						},
						onUpdate: function(twn:FlxTween)
						{
							if (callbacks.updateCallback != null)
								callbacks.updateCallback();
						},
						onComplete: function(twn:FlxTween)
						{
							if (callbacks.endCallback != null)
								callbacks.endCallback();
						}
					});

					new FlxTimer().start(duration / 12, function(tmr:FlxTimer)
					{
						black.alpha += (1 / 12) * (fade == Out ? -1.0 : 1.0);
					}, 12);
				}
			default: // null
				{
					if (callbacks.startCallback != null)
						callbacks.startCallback();
					if (callbacks.endCallback != null)
						callbacks.endCallback();
				}
		}

		transIn = true;
		transOut = true;
	}

	public static function fromString(string:String):TransitionType
	{
		if (string.contains('Pixel'))
		{
			switch (string)
			{
				case 'Pixel_Slider_Down':
					return Pixel_Slider_Down;
				case 'Pixel_Slider_Up':
					return Pixel_Slider_Up;
				case 'Pixel_Slider_Left':
					return Pixel_Slider_Left;
				case 'Pixel_Slider_Right':
					return Pixel_Slider_Right;
				default:
					return Pixel_Fade;
			}
		}
		else
		{
			switch (string)
			{
				case 'Slider_Down':
					return Slider_Down;
				case 'Slider_Up':
					return Slider_Up;
				case 'Slider_Left':
					return Slider_Left;
				case 'Slider_Right':
					return Slider_Right;
				default:
					return Fade;
			}
		}
	}
}

typedef Callbacks =
{
	@:optional var startCallback:Void->Void;
	@:optional var updateCallback:Void->Void;
	@:optional var endCallback:Void->Void;
}

enum TransitionType
{
	None;
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
