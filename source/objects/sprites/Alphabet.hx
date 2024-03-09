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

	public var alpha:Float = 1.0;

	public var bakedRotationAngle(default, null):Float = 0;

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

	private var _flashPoint:Point;

	private var _flashRect:Rectangle;
	private var _flashRect2:Rectangle;

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
						FlxG.log.error('Could not create a hash for "${output}');
				}
			}
		}
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

			//i f (isSimpleRender())
				drawSimple();
			/*else
				drawComplex();*/
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
			var animToPlay:String = getAnimName(text.charAt(i)); 
			var _frame:FlxFrame = null;
			if (Alphabet.animationHash.exists(animToPlay))
				_frame = Alphabet.animationHash.get(animToPlay)[curFrame];

			var _pixels:BitmapData = _frame.parent.bitmap;

			_flashRect.setTo(0, 0, _frame.frame.width, _frame.frame.height);
			
			getScreenPosition(_point, camera);
			_point.add(_addedPoint.x, _addedPoint.y);
			if (isPixelPerfectRender(camera))
				_point.floor();

			_addedPoint.add(_flashRect.width, 0);
			
			if (!camera.containsPoint(_point, _flashRect.width, _flashRect.height))
				continue;

			_point.copyToFlash(_flashPoint);
			camera.copyPixels(_frame, _pixels, _flashRect, _flashPoint, colorTransform, blend, antialiasing);
		}

		width = Math.max(_flashPoint.x + _flashRect.width - x, width);
		height = Math.max(_flashPoint.y + _flashRect.height - y, height);
	}

	function drawComplex():Void
	{
		for (i in 0...text.length)
		{
			var animToPlay:String = getAnimName(text.charAt(i)); 
		}
	}

	public function isSimpleRender(?camera:FlxCamera):Bool
	{
		if (FlxG.renderTile)
			return false;

		return isSimpleRenderBlit(camera);
	}

	public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		var result:Bool = (angle == 0 || bakedRotationAngle > 0) && scale.x == 1 && scale.y == 1 && blend == null;
		result = result && (camera != null ? isPixelPerfectRender(camera) : pixelPerfectRender);
		return result;
	}

	override function initVars():Void
	{
		super.initVars();

		_flashPoint = new Point();
		_flashRect = new Rectangle();
		_flashRect2 = new Rectangle();
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
		FlxG.log.error('Attempting to use frames that belong to a destroyed graphic, frame names: $names');
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
}
