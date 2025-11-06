package crow.objects.dependencies;

import crow.objects.dependencies.AbsolutePositionSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.text.FlxText;

/**
 * A `FlxText` that ignores camera scrolling, always rendering at its absolute screen position.
 *
 * Some functionalities here are not made for modding or modifiable by game data components.
 */
class AbsolutePositionText extends FlxText implements IAbsolutePositionBasic
{
	private var _internalOffset:FlxPoint;

	override function initVars():Void
	{
		super.initVars();
		_internalOffset = FlxPoint.get();
	}

	override public function draw()
	{
		regenGraphic();
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

		getPosition(_point).addPoint(_internalOffset); // use absolute position
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
