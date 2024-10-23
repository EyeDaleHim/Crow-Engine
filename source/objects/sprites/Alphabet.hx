package objects.sprites;

enum Alignment
{
	LEFT;
	CENTERED;
	RIGHT;
}

class Alphabet extends FlxObject
{
	public static var animationHash:Map<String, Array<FlxFrame>>;

	public var antialiasing:Bool = FlxSprite.defaultAntialiasing;

	public var alpha(default, set):Float = 1.0;

	public var blend:BlendMode;

	public var color:FlxColor = 0xFFFFFFFF;
	public var colorTransform:ColorTransform;

	public var scale:FlxPoint = FlxPoint.get(1.0, 1.0);

	public var frames:FlxFramesCollection;

	public var text:String = "";
	public var bold:Bool = false;
	public var alignment:Alignment = LEFT;

	public var curFrame:Int = 0;
	public var startFrame:Int = 0;
	public var endFrame:Int = 3;

	public var frameRate:Float = 24.0;

	private var _lastSize:FlxPoint;

	private var _flashPoint:Point;
	private var _flashRect:Rectangle;

	private var _matrix:FlxMatrix;

	public function new(?x:Float = 0, ?y:Float = 0, text:String = "", bold:Bool = true, alignment:Alignment = LEFT)
	{
		super(x, y);

		this.text = text;
		this.bold = bold;
		this.alignment = alignment;

		frames = Assets.frames('alphabet');

		if (animationHash == null && frames != null)
		{
			animationHash = new Map();

			var types:Array<String> = ['bold', 'capital', 'lowercase'];
			var letters:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
			var numbers:String = '0123456789';

			for (type in types)
			{
				if (type == 'lowercase')
					letters = letters.toLowerCase();

				for (i in 0...letters.length)
				{
					final letter:String = letters.charAt(i);
					final output:String = '$letter $type';
					final animFrames:Array<FlxFrame> = new Array<FlxFrame>();

					findByPrefix(animFrames, output); // adds valid frames to animFrames

					if (animFrames.length > 0)
						animationHash.set(output, animFrames);
					else
						Logs.error('Could not create a hash for "${output}');
				}
			}

			for (suffix in ['', ' bold'])
			{
				for (i in 0...numbers.length)
				{
					final number:String = numbers.charAt(i);
					final output:String = '$number$suffix';
					final animFrames:Array<FlxFrame> = new Array<FlxFrame>();

					findByPrefix(animFrames, output); // adds valid frames to animFrames

					if (animFrames.length > 0)
						animationHash.set(output, animFrames);
					else
						Logs.error('Could not create a hash for "${output}');
				}
			}
		}

		if (isSimpleRender())
			drawSimple();
		else
			drawComplex();
	}

	private var _frameTime:Float = 0.0;

	override public function update(elapsed:Float)
	{
		_frameTime += elapsed;

		while (_frameTime >= 1 / frameRate)
		{
			curFrame++;

			if (curFrame > endFrame)
				curFrame = startFrame;

			_frameTime -= 1 / frameRate;
		}

		super.update(elapsed);
	}

	override public function draw()
	{
		if (alpha == 0 || text.length == 0)
			return;

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists || !isOnScreen(camera))
				continue;

			setSize(0, 0);

			if (isSimpleRender())
				drawSimple();
			else
				drawComplex();
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	function getAnimName(char:String):String
	{
		var lowercase:String = char.toLowerCase();

		var suffix:String = '';
		if (!bold)
		{
			if (lowercase != char)
				suffix = ' capital';
			else
				suffix = ' lowercase';
		}
		else
		{
			char = char.toUpperCase();
			suffix = ' bold';
		}

		return char + suffix;
	}

	function drawSimple():Void
	{
		var _addedPoint:FlxPoint = FlxPoint.get();

		for (i in 0...text.length)
		{
			var char:String = text.charAt(i);

			switch (char)
			{
				case " ":
					{
						_addedPoint.add(40);
						continue;
					}
				case '\n':
					{
						_addedPoint.set(0, height);
						continue;
					}
			}

			var animToPlay:String = getAnimName(char);
			var _frame:FlxFrame = null;
			if (Alphabet.animationHash.exists(animToPlay))
				_frame = Alphabet.animationHash.get(animToPlay)[curFrame];
			else
			{
				_addedPoint.add(40);
				Logs.error('Alphabet character ${char} is invalid.');
				continue;
			}

			var _pixels:BitmapData = _frame.parent.bitmap;

			_flashRect.setTo(0, 0, _frame.sourceSize.x, _frame.sourceSize.y);

			getScreenPosition(_point, camera);

			if (!bold)
				_flashRect.width += 2;

			_point.add(_addedPoint.x, _addedPoint.y);

			if (isPixelPerfectRender(camera))
				_point.floor();

			_addedPoint.add(_flashRect.width, 0);

			_point.copyToFlash(_flashPoint);
			camera.copyPixels(_frame, _pixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
		}

		width = Math.max(_flashPoint.x + _flashRect.width, width);
		height = Math.max(_flashPoint.y + _flashRect.height, height);
	}

	function drawComplex():Void
	{
		var _addedPoint:FlxPoint = FlxPoint.get();
		var sizeRect:FlxPoint = FlxPoint.get();

		for (i in 0...text.length)
		{
			var char:String = text.charAt(i);

			switch (char)
			{
				case " ":
					{
						_addedPoint.add(40 * scale.x);
						continue;
					}
				case '\n':
					{
						_addedPoint.set(0, height * scale.y);
						continue;
					}
			}

			var animToPlay:String = getAnimName(char);
			var _frame:FlxFrame = null;
			if (Alphabet.animationHash.exists(animToPlay))
				_frame = Alphabet.animationHash.get(animToPlay)[curFrame];
			else
			{
				_addedPoint.add(40 * scale.x);
				Logs.error('Alphabet character ${char} is invalid.');
				continue;
			}

			var _pixels:BitmapData = _frame.parent.bitmap;

			_flashRect.setTo(0, 0, _frame.sourceSize.x, _frame.sourceSize.y);

			var center:FlxPoint = FlxPoint.get(_flashRect.width / 2, _flashRect.height / 2);

			_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, false, false);
			_matrix.translate(-center.x, -center.y);
			_matrix.scale(scale.x, scale.y);

			getScreenPosition(_point, camera);

			if (!bold)
				_flashRect.width += 2;

			_point.add(center.x, center.y);
			_matrix.translate(_point.x, _point.y);
			_matrix.translate(_addedPoint.x, _addedPoint.y);

			center.put();

			if (isPixelPerfectRender(camera))
			{
				_matrix.tx = Math.floor(_matrix.tx);
				_matrix.ty = Math.floor(_matrix.ty);
			}

			_addedPoint.add(_flashRect.width * scale.x, 0);

			sizeRect.set(_addedPoint.x, _addedPoint.y + Math.max(_flashRect.height, sizeRect.y));

			if (!camera.containsPoint(_point, _flashRect.width * scale.x, _flashRect.height * scale.y))
				continue;

			_point.copyToFlash(_flashPoint);
			camera.drawPixels(_frame, _pixels, _matrix, colorTransform, blend, antialiasing);
		}

		setSize(sizeRect.x, sizeRect.y);
	}

	public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (FlxG.renderTile)
			return false;

		return scale.x == 1 && scale.y == 1;
	}

	override function initVars():Void
	{
		super.initVars();

		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_matrix = new FlxMatrix();

		_lastSize = FlxPoint.get(width, height);

		colorTransform = new ColorTransform();
		scale = FlxPoint.get(1, 1);
	}

	function findSpriteFrame(prefix:String, index:Int, postfix:String):Int
	{
		for (i in 0...frames.frames.length)
		{
			final frame = frames.frames[i];
			final name = frame.name;
			if (name.startsWith(prefix) && name.endsWith(postfix))
			{
				final frameIndex:Null<Int> = Std.parseInt(name.substring(prefix.length, name.length - postfix.length));
				if (frameIndex == index)
					return i;
			}
		}

		return -1;
	}

	function findByPrefix(animFrames:Array<FlxFrame>, prefix:String, logError = true):Void
	{
		for (frame in frames.frames)
		{
			if (frame.name != null && frame.name.startsWith(prefix))
			{
				animFrames.push(frame);
			}
		}

		// prevent and log errors for invalid frames
		final invalidFrames = removeInvalidFrames(animFrames);
		#if FLX_DEBUG
		if (invalidFrames.length == 0 || !logError)
			return;

		final names = invalidFrames.map((f) -> '"${f.name}"').join(", ");
		Logs.error('Attempting to use frames that belong to a destroyed graphic, frame names: $names');
		#end
	}

	function removeInvalidFrames(frames:Array<FlxFrame>)
	{
		final invalid:Array<FlxFrame> = [];
		var i = frames.length;
		while (i-- > 0)
		{
			final frame = frames[i];
			if (frame.parent.shader == null)
				invalid.unshift(frames.splice(i, 1)[0]);
		}

		return invalid;
	}

	function set_alpha(value:Float)
	{
		value = FlxMath.bound(value, 0, 1);

		if (value != 1 || color != 0xffffff)
			colorTransform.setMultipliers(color.redFloat, color.greenFloat, color.blueFloat, value);
		else
			colorTransform.setMultipliers(1, 1, 1, 1);

		return (alpha = value);
	}
}
