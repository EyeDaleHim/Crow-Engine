package gear.objects.ui;

import gear.assets.metadata.GlyphMetadata;

class AnimatedText extends FlxTypedSpriteContainer<AnimatedTextLine>
{
    /**
     * The metadata of the glyph. This contains information for how characters are spaced
     * between each other, how line breaks work, etc.
     */
    public var glyph:GlyphMetadata;

    /**
     * The content to display.
     */
    public var text:String = "";

    /**
     * The width of the text field.
     * If 0, it will automatically adjust to the text's width.
     */
    public var fieldWidth:Float = 0.0;

    public function new(?x:Float = 0.0, ?y:Float = 0.0, framesPath:String, glyphPath:String, ?text:String = "")
    {
        super(x, y);

        this.text = text;

        frames = Assets.frames(framesPath);

        final glyphsDir = "display/glyphs";
		final rawJson = FlxG.assets.getTextUnsafe(Path.join([glyphsDir, '$glyphPath.json']));
		if (rawJson == null)
		{
			this.glyph = [];
			return;
		}

		try
		{
			this.glyph = cast Json.parse(rawJson);
		}
		catch (e)
		{
			trace('Error parsing glyph file $glyphPath: $e');
			this.glyph = [];
		}
    }

    override function destroy()
    {
        super.destroy();
        glyph = null;
    }
}

// This will draw each glyph in a batch instead of dedicating a sprite for each glyph.
class AnimatedTextLine extends FlxSprite
{
    public var parentText:AnimatedText;
    
    public function new(parent:AnimatedText)
    {
        super();
        this.parentText = parent;
    }
}