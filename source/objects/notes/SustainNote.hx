package objects.notes;

import flixel.graphics.frames.FlxFrame;

class SustainNote extends FlxSprite
{
	public var noteData(default, set):Note;
	public var wrap:WrapMode = STRETCH;
	public var length(default, set):Float = 0.0;

	public var endNoteFrame:FlxFrame;

	override public function new(noteData:Note, wrap:WrapMode = STRETCH, length:Float = 0.0)
	{
		super();

		frames = Assets.frames("game/ui/NOTE_assets");

		animation.addByPrefix("noteLEFT", "purple hold piece", 24);
		animation.addByPrefix("noteDOWN", "blue hold piece", 24);
		animation.addByPrefix("noteUP", "green hold piece", 24);
		animation.addByPrefix("noteRIGHT", "red hold piece", 24);

		animation.addByPrefix("noteLEFTend", "pruple end hold", 24);
		animation.addByPrefix("noteDOWNend", "blue hold end", 24);
		animation.addByPrefix("noteUPend", "green hold end", 24);
		animation.addByPrefix("noteRIGHTend", "red hold end", 24);

		this.noteData = noteData;
		this.length = length;
		this.wrap = wrap;
	}

	override public function drawComplex(camera:FlxCamera):Void
	{
		if (wrap == STRETCH)
		{
			var heightRemainder:Float = 0.0;
			if (endNoteFrame != null)
			{
				heightRemainder = (frameHeight * scale.y) - endNoteFrame.frame.height;
			}

			heightRemainder /= frameHeight * scale.y;

			// render sustain...
			_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
			_matrix.translate(-origin.x, -origin.y);
			_matrix.scale(scale.x, scale.y);

			if (bakedRotationAngle <= 0)
			{
				updateTrig();

				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			getScreenPosition(_point, camera).subtractPoint(offset);
			_point.add(origin.x, origin.y);
			_matrix.translate(_point.x, _point.y);

			if (isPixelPerfectRender(camera))
			{
				_matrix.tx = Math.floor(_matrix.tx);
				_matrix.ty = Math.floor(_matrix.ty);
			}

			camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);

			if (endNoteFrame != null)
			{
				_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, 0.7);

				if (bakedRotationAngle <= 0)
				{
					updateTrig();

					if (angle != 0)
						_matrix.rotateWithTrig(_cosAngle, _sinAngle);
				}

				getScreenPosition(_point, camera).subtractPoint(offset);
				_point.add(origin.x, origin.y);

				_matrix.translate(_point.x, _point.y + (frameHeight * scale.y));

				if (isPixelPerfectRender(camera))
				{
					_matrix.tx = Math.floor(_matrix.tx);
					_matrix.ty = Math.floor(_matrix.ty);
				}

				camera.drawPixels(endNoteFrame, endNoteFrame.parent.bitmap, _matrix, colorTransform, blend, antialiasing, shader);
			}
		}
		else if (wrap == TILE)
		{
			var totalHeight:Int = height.floor();

			var _offset:Float = 0.0;

			while (totalHeight >= _frame.frame.height)
			{
				_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
				_matrix.translate(-origin.x, -origin.y);
				_matrix.scale(scale.x, 1.0);

				getScreenPosition(_point, camera).subtractPoint(offset);
				_point.add(origin.x, origin.y);

				_matrix.translate(_point.x, _point.y);
				_matrix.translate(0.0, _offset);

				_offset += _frame.frame.height;
				totalHeight -= _frame.frame.height.floor();

				if (isPixelPerfectRender(camera))
				{
					_matrix.tx = Math.floor(_matrix.tx);
					_matrix.ty = Math.floor(_matrix.ty);
				}

				camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
			}
		}
	}

	override public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		return false;
	}

	function set_length(value:Float)
	{
		setGraphicSize(frameWidth * 0.7, value * 0.45);
		updateHitbox();

		return (this.length = value);
	}

	function set_noteData(noteData:Note)
	{
		if (noteData != null)
		{
			var anim:String = "";

			switch (noteData.direction)
			{
				case 0:
					anim = "noteLEFT";
				case 1:
					anim = "noteDOWN";
				case 2:
					anim = "noteUP";
				case 3:
					anim = "noteRIGHT";
			}

			animation.play(anim);
			if (frames.exists('$anim${'end'}'))
			{
				frames.getByName('$anim${'end'}').copyTo(endNoteFrame);
			}

			noteData.sustainParent = this;
		}

		return (this.noteData = noteData);
	}
}

enum WrapMode
{
	STRETCH;
	TILE;
}
