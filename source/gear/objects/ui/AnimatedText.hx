package gear.objects.ui;

import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.frames.FlxFrame;
import gear.assets.metadata.AnimatedFontMetadata;
import gear.assets.metadata.GlyphMetadata;

using flixel.util.FlxColorTransformUtil;

class AnimatedText extends FlxTypedSpriteContainer<AnimatedTextLine>
{
	/**
	 * It also has the metadata of the glyphs, which contains information for how characters are spaced
	 * between each other, how line breaks work, etc.
	 */
	public var font:AnimatedFontMetadata;

	/**
	 * The content to display.
	 */
	public var text(default, set):String = "";

	/**
	 * The width of the text field.
	 * If 0, it will automatically adjust to the text's width.
	 */
	public var fieldWidth(default, set):Float = 0.0;

	/**
	 * The alignment of the text.
	 */
	public var alignment(default, set):TextAlignment = LEFT;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, path:String, ?text:String = "")
	{
		super(x, y);

		final fontsDir = "fonts/animated";
		final rawJson = FlxG.assets.getTextUnsafe(Path.join([fontsDir, '$path.json']));
		if (rawJson == null)
		{
			font = {glyphs: [], framesPath: ""};
			return;
		}

		try
		{
			font = cast Json.parse(rawJson);
		}
		catch (e)
		{
			trace('Error parsing font file $path: $e');
			font = {glyphs: [], framesPath: ""};
		}

		this.text = text;

		regenerate();
	}

	private function regenerate():Void
	{
		final lines = text.split("\n");
		var lineY:Float = 0;

		for (i in 0...lines.length)
		{
			var line:AnimatedTextLine;
			if (i < members.length)
			{
				line = members[i];
				if (line.text != lines[i])
				{
					line.updateGlyphs(lines[i]);
				}
			}
			else
			{
				line = new AnimatedTextLine(this, lines[i]);
				add(line);
			}
			line.y = y + lineY;
			lineY += line.height; // This will be calculated in updateGlyphs
		}

		var i = members.length - 1;
		while (i >= lines.length)
		{
			var member = remove(members[i], true);
			member.destroy();
			i--;
		}

		updateAlignment();
	}

	override function destroy()
	{
		super.destroy();
		font = null;
	}

	private function set_text(value:String):String
	{
		if (text == value)
			return value;

		text = value;
		regenerate();
		return value;
	}

	private function set_fieldWidth(value:Float):Float
	{
		if (fieldWidth == value)
			return value;

		fieldWidth = value;
		// TODO: Implement word wrapping behavior. For now, it just updates line widths.
		updateAlignment();
		return value;
	}

	private function set_alignment(value:TextAlignment):TextAlignment
	{
		if (alignment == value)
			return value;

		alignment = value;
		updateAlignment();
		return value;
	}

	private function updateAlignment():Void
	{
		var maxWidth:Float = fieldWidth;
		if (maxWidth == 0)
		{
			// If fieldWidth is 0, find the widest line to align against.
			for (line in members)
			{
				@:privateAccess
				if (line._textWidth > maxWidth)
					maxWidth = line._textWidth;
			}
		}

		for (line in members)
		{
			line.alignIn(maxWidth, alignment);
		}
	}

	override function get_width():Float
	{
		if (fieldWidth > 0)
			return x + fieldWidth;

		var maxWidth:Float = 0;
		if (members != null)
		{
			for (line in members)
			{
				@:privateAccess
				if (line._textWidth > maxWidth)
				{
					maxWidth = line._textWidth;
				}
			}
		}
		return x + maxWidth;
	}
}

// This will draw each glyphs in a batch instead of dedicating a sprite for each glyphs.
class AnimatedTextLine extends FlxSprite
{
	public var parentText:AnimatedText;

	public var text:String;
	public var lineWidth:Float = 0.0; // 0.0 means auto
	
	private var _drawableGlyphs:Array<DrawableGlyph> = [];
	private var _textWidth:Float = 0.0;
	private var _animationStates:Map<String, {curFrame:Int, timer:Float}> = [];

	/**
	 * The frame rate of the animations, in frames per second.
	 */
	public var frameRate(default, set):Float = 24;

	public function new(parent:AnimatedText, text:String)
	{
		super();

		this.parentText = parent;
		this.frames = Main.assets.frames(parentText.font.framesPath);
		this.frameRate = parentText.font.frameRate ?? 24;

		// Copy animations from the parent
		for (glyph in parentText.font.glyphs)
		{
			if (glyph.animationPrefix != null && glyph.animationPrefix != "")
			{
				for (char in glyph.chars)
				{
					animation.addByPrefix(char, glyph.animationPrefix, 24, false);
				}
			}
		}

		updateGlyphs(text);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (frameRate <= 0)
			return;

		final frameDelay = 1 / frameRate;
		for (char in _animationStates.keys())
		{
			final state = _animationStates.get(char);
			final anim = animation.getByName(char);
			if (anim != null && anim.frames.length > 1)
			{
				state.timer += elapsed;
				if (state.timer >= frameDelay)
				{
					state.curFrame = (state.curFrame + 1) % anim.frames.length;
					state.timer -= frameDelay;
				}
			}
		}
	}

	private function set_frameRate(value:Float):Float
	{
		if (frameRate == value)
			return value;
		frameRate = value;
		return value;
	}

	public function alignIn(width:Float, alignment:TextAlignment):Void
	{
		final newWidth = Math.max(width, _textWidth);

		switch (alignment)
		{
			case LEFT:
				x = parentText.x;
			case RIGHT:
				x = parentText.x + newWidth - _textWidth;
			case CENTER:
				x = parentText.x + (newWidth - _textWidth) / 2;
			case _:
				x = parentText.x;
		}
		this.lineWidth = width;
	}

	override public function draw()
	{
		if (alpha == 0 || _frame.type == FlxFrameType.EMPTY)
			return;

		for (camera in getCamerasLegacy())
		{
			if (!camera.visible || !camera.exists)
				continue;

			final transform = parentText.colorTransform;

			final isColored = (transform != null #if !html5 && transform.hasRGBMultipliers() #end);
			final hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());

			var batch:FlxDrawQuadsItem = camera.startQuadBatch(frames.parent, isColored, hasColorOffsets, parentText.blend, parentText.antialiasing,
				parentText.shader);
			var matrix = this._matrix;
			for (drawable in _drawableGlyphs)
			{
				final anim = animation.getByName(drawable.char);
				if (anim == null || anim.frames.length == 0)
					continue;

				var frameIndex = 0;
				if (_animationStates.exists(drawable.char))
				{
					frameIndex = _animationStates.get(drawable.char).curFrame;
				}

				final frame = frames.frames[anim.frames[frameIndex]];
				if (frame == null)
					continue;

				matrix.identity();
				getScreenPosition(_point, camera).subtract(offset);
				matrix.translate(_point.x, _point.y);
				matrix.translate(drawable.x, drawable.y);
				matrix.scale(scale.x, scale.y);

				if (isPixelPerfectRender(camera))
				{
					matrix.tx = Math.floor(matrix.tx);
					matrix.ty = Math.floor(matrix.ty);
				}

				batch.addQuad(frame, matrix, transform);
			}

			#if FLX_DEBUG
			FlxBasic.visibleCount++;
			#end
		}

		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}

	public function updateGlyphs(text:String):Void
	{
		_drawableGlyphs = [];
		_animationStates = [];
		this.text = text;

		// First pass: determine line height and gather glyph data
		var lineMaxHeight:Float = 0;
		var glyphsToProcess:Array<{char:String, glyphData:Glyph, frame:FlxFrame}> = [];
		for (char in text.split(""))
		{
			var glyphData:Null<Glyph> = null;
			for (g in parentText.font.glyphs)
			{
				if (g.chars.indexOf(char) != -1)
				{
					glyphData = g;
					break;
				}
			}

			if (glyphData == null)
				continue;

			var frame:FlxFrame = null;
			if (glyphData.animationPrefix != null)
			{
				final anim = animation.getByName(char);
				if (anim != null && anim.frames.length > 0)
				{
					if (!_animationStates.exists(char))
					{
						_animationStates.set(char, {
							curFrame: 0,
							timer: 0.0
						});
					}
					frame = frames.frames[anim.frames[0]];
				}
			}

			glyphsToProcess.push({char: char, glyphData: glyphData, frame: frame});

			// Determine line height from the tallest glyph
			if (frame != null && frame.sourceSize.y > lineMaxHeight)
				lineMaxHeight = frame.sourceSize.y;
		}

		// Second pass: create drawable glyphs with correct positions
		var currentX:Float = 0;
		for (item in glyphsToProcess)
		{
			final glyphData = item.glyphData;
			final frame = item.frame;

			var glyphY:Float = (glyphData.offsetY ?? 0);
			switch (glyphData.baseline)
			{
				case "center":
					glyphY += (lineMaxHeight - (frame != null ? frame.sourceSize.y : 0)) / 2;
				case "bottom":
					glyphY += lineMaxHeight - (frame != null ? frame.sourceSize.y : 0);
				case "top" | _: // "top" is default
			}

			final drawable:DrawableGlyph = {
				char: item.char,
				glyph: glyphData,
				x: currentX + (glyphData.offsetX ?? 0),
				y: glyphY
			};
			_drawableGlyphs.push(drawable);

			currentX += (frame != null ? frame.sourceSize.x : 0) + (glyphData.advanceX ?? 0);
		}

		_textWidth = currentX;
		setSize(_textWidth, lineMaxHeight);
	}
}

private typedef DrawableGlyph =
{
	char:String,
	glyph:Glyph,
	x:Float,
	y:Float
}

enum abstract TextAlignment(String)
{
	var LEFT = "left";
	var CENTER = "center";
	var RIGHT = "right";
}
