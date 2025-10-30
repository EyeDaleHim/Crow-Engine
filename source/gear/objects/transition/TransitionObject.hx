package gear.objects.transition;

import gear.objects.dependencies.AbsolutePositionSprite;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import openfl.geom.Point;

/**
 * Creates a 1280x720 + (1280x72) FlxSprite. The first part is simply a box, the second part is a vertical gradient.
 * 
 * To create in-and-out transitions, you simply flip the sprite.
 * 
 * In some cases, the original behavior is enough, but you may take use of startIn() and startOut() to create
 * your own transitions.
 */
class TransitionObject extends AbsolutePositionSprite
{
	public static final transitionGraphicKey:String = 'transition_graphic';

	public var tween:FlxTween;

	public function new()
	{
		super();

		if (!FlxG.bitmap.checkCache(transitionGraphicKey))
		{
			var bmd = new BitmapData(FlxG.width, Math.floor(FlxG.height + (FlxG.height * 0.1)), true, 0xFFFFFFFF);
			var gradient = FlxGradient.createGradientBitmapData(FlxG.width, Math.floor(FlxG.height * 0.1), [FlxColor.WHITE, FlxColor.TRANSPARENT], 1, 90);

			bmd.copyPixels(gradient, gradient.rect, new Point(0, 720));
			FlxG.bitmap.add(bmd, false, transitionGraphicKey);
		}

		loadGraphic(FlxG.bitmap.get(transitionGraphicKey));

		kill();
	}

	public function startIn(?callback:() -> Void):Void
	{
		revive();
		flipY = true;

		if (tween != null)
		{
			tween.cancel();
		}

		y = -(FlxG.height * 0.1);
		tween = FlxTween.tween(this, {y: height}, 0.5, {
			onComplete: (_) ->
			{
				kill();
				if (callback != null)
				{
					callback();
				}
			}
		});
	}

	public function startOut(?callback:() -> Void):Void
	{
		revive();
		flipY = false;

		y = -height;
		if (tween != null)
		{
			tween.cancel();
		}

		tween = FlxTween.tween(this, {y: 0.0}, 0.5, {
			onComplete: (_) ->
			{
				kill();
				if (callback != null)
				{
					callback();
				}
			}
		});
	}
}
