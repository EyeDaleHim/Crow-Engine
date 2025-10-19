package gear.objects.ui;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
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
class TransitionObject extends FlxSprite
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

	override public function draw()
	{
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		final matrix = this._matrix; // TODO: Just use local?
		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		matrix.translate(-origin.x, -origin.y);
		matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getPosition(_point); // use absolute position
		_point.add(origin.x, origin.y);
		matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, matrix, colorTransform, blend, antialiasing, shader);

		#if FLX_DEBUG
		FlxBasic.visibleCount++;

		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
}
