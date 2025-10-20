package gear.objects.ui;

import flixel.animation.FlxAnimationController;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import gear.assets.metadata.GlyphMetadata;
import gear.assets.Assets;

using flixel.util.FlxColorTransformUtil;

class AnimatedText extends FlxTypedSpriteContainer<AnimatedTextLine>
{
	/**
	 * The metadata of the glyphs. This contains information for how characters are spaced
	 * between each other, how line breaks work, etc.
	 */
	public var glyphs:GlyphMetadata;

	/**
	 * The content to display.
	 */
	public var text:String = "";

	/**
	 * The width of the text field.
	 * If 0, it will automatically adjust to the text's width.
	 */
	public var fieldWidth:Float = 0.0;

	/**
	 * The alignment of the text.
	 */
	public var alignment:TextAlignment = LEFT;

	public var framesReference:FlxFramesCollection;

	public function new(?x:Float = 0.0, ?y:Float = 0.0, framesPath:String, glyphPath:String, ?text:String = "")
	{
		super(x, y);

		this.text = text;

		framesReference = Main.assets.frames(framesPath);

		final glyphsDir = "display/glyphs";
		final rawJson = FlxG.assets.getTextUnsafe(Path.join([glyphsDir, '$glyphPath.json']));
		if (rawJson == null)
		{
			this.glyphs = [];
			return;
		}

		try
		{
			this.glyphs = cast Json.parse(rawJson);
		}
		catch (e)
		{
			trace('Error parsing glyph file $glyphPath: $e');
			this.glyphs = [];
		}

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
	}

	override function destroy()
	{
		super.destroy();
		glyphs = null;
	}
}

// This will draw each glyphs in a batch instead of dedicating a sprite for each glyphs.
class AnimatedTextLine extends FlxSprite
{
	public var parentText:AnimatedText;

	public var text:String;
	public var lineWidth:Float = 0.0; // 0.0 means auto

	public var alignment:TextAlignment = LEFT;

	private var _drawableGlyphs:Array<DrawableGlyph> = [];
	private var _alignmentStartX:Float = 0.0;

	public function new(parent:AnimatedText, alignment:TextAlignment = LEFT, lineWidth:Float = 0.0, text:String)
	{
		super();
		this.parentText = parent;

		this.frames = parentText.framesReference;

		this.text = text;
		this.lineWidth = lineWidth;

		this.alignment = alignment;

		// Copy animations from the parent
		for (glyph in parentText.glyphs)
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

			var batch:FlxDrawQuadsItem = camera.startQuadBatch(frames.parent, isColored, hasColorOffsets, blend, antialiasing, shader);
			var matrix = this._matrix;
			for (drawable in _drawableGlyphs)
			{
				final anim = animation.getByName(drawable.char);
				if (anim == null || anim.frames.length == 0)
					continue;

				// Single frame for now
				final frame = frames.frames[anim.frames[0]];
				if (frame == null)
					continue;

				matrix.identity();
				getScreenPosition(_point, camera).subtract(offset);
				matrix.translate(_point.x, _point.y);
				matrix.translate(x + drawable.x + _alignmentStartX, y + drawable.y);
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
		this.text = text;

		var currentX:Float = 0;
		var lineMaxHeight:Float = 0;

		for (char in text.split(""))
		{
			var glyphData:Null<Glyph> = null;
			for (g in parentText.glyphs)
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
					frame = frames.frames[anim.frames[0]];
				}
			}

			final drawable:DrawableGlyph = {
				char: char,
				glyph: glyphData,
				x: currentX + (glyphData.offsetX ?? 0),
				y: (glyphData.offsetY ?? 0)
			};
			_drawableGlyphs.push(drawable);

			currentX += (frame != null ? frame.sourceSize.x : 0) + (glyphData.advanceX ?? 0);

			// Determine line height from the tallest glyph
			if (frame != null && frame.sourceSize.y > lineMaxHeight)
			{
				lineMaxHeight = frame.sourceSize.y;
			}
		}

		final newWidth = Math.max(lineWidth, currentX);

		switch (alignment)
		{
			case LEFT:
				_alignmentStartX = 0;
			case RIGHT:
				_alignmentStartX = newWidth - currentX;
			case CENTER:
				_alignmentStartX = (newWidth - currentX) / 2;
			case _:
				_alignmentStartX = 0;
		}
		makeGraphic(Math.ceil(newWidth), Math.ceil(lineMaxHeight), FlxColor.TRANSPARENT, true);
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
