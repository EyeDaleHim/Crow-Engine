package crow.objects.dependencies;

import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;

/**
 * A `FlxSprite` that ignores camera scrolling, always rendering at its absolute screen position.
 * 
 * Some functionalities here are not made for modding or modifiable by game data components.
 */
@:allow(AbsolutePositionSpriteList)
class AbsolutePositionSprite extends FlxSprite implements IAbsolutePositionBasic
{
	public var object:FlxSprite;

	private var _internalOffset:FlxPoint;
	private var _internalAlphaMult:Float = 1.0;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, ?wrappedObject:FlxSprite)
	{
		super(x, y);

		if (wrappedObject != null)
			object = wrappedObject;
		else
			object = this;
	}

	override function initVars():Void
	{
		super.initVars();
		_internalOffset = FlxPoint.get();
	}

	override public function draw()
	{
		drawWithModifiers(_internalOffset, _internalAlphaMult);

		#if FLX_DEBUG
		FlxBasic.visibleCount++;

		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	public function drawWithModifiers(?offset:FlxPoint, ?multAlpha:Float)
	{
		switch (Type.getClass(object))
		{
			case FlxText:
			{
				@:privateAccess
				cast(object, FlxText).regenGraphic();
			}
		}

		final totalAlpha:Float = object.alpha * (multAlpha ?? 1.0);

		if (totalAlpha == 0 || object._frame.type == FlxFrameType.EMPTY)
			return;

		final matrix = object._matrix; // TODO: Just use local?
		object.frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, object.checkFlipX(), object.checkFlipY());
		matrix.translate(-object.origin.x, -object.origin.y);
		matrix.scale(object.scale.x, object.scale.y);

		if (object.bakedRotationAngle <= 0)
		{
			object.updateTrig();

			if (object.angle != 0)
				matrix.rotateWithTrig(object._cosAngle, object._sinAngle);
		}

		object.getPosition(_point).addPoint(offset ?? FlxPoint.weak()); // use absolute position
		_point.add(object.origin.x, object.origin.y);
		matrix.translate(_point.x, _point.y);

		if (object.isPixelPerfectRender(object.getDefaultCamera()))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}

		final formerAlpha = alpha;
		object.colorTransform.alphaMultiplier = totalAlpha;
		object.getDefaultCamera()
			.drawPixels(object._frame, object.framePixels, matrix, object.colorTransform, object.blend, object.antialiasing, object.shader);
		object.colorTransform.alphaMultiplier = formerAlpha;
	}

	@:access(flixel.FlxCamera)
	override function getBoundingBox(camera:FlxCamera):FlxRect
	{
		getPosition(_point).addPoint(_internalOffset); // use absolute position

		_rect.set(_point.x, _point.y, width, height);
		_rect = camera.transformRect(_rect);

		if (isPixelPerfectRender(camera))
		{
			_rect.floor();
		}

		return _rect;
	}
}

interface IAbsolutePositionBasic
{
	private var _internalOffset:FlxPoint;
}
