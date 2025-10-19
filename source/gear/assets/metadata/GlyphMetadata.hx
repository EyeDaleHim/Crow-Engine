package gear.assets.metadata;

typedef GlyphMetadata = Array<Glyph>;

typedef Glyph =
{
	/**
	 * The unicode characters that this glyph represents.
	 * You do not need to define one character, you can define multiple characters for
	 * interesting effects like emojis, assuming they are formatted correctly.
	 * 
     * Case-sensitive.
	 */
	var chars:Array<UnicodeString>;

	/**
	 * The animation to play when this glyph is displayed.
     * All frames with the prefix will only be included.
	 */
	var ?animationPrefix:String;

	/**
	 * Whether this glyph is a whitespace, which will let the glyph
	 * ignore animationPrefix and act as an offsetter.
	 * 
	 * An example of a whitespace character is the space character (" ") 
	 */
	var ?presentsWhitespace:Bool;

	/**
	 * The amount to advance the next characters horizontally after drawing this glyph.
     * Note that advanceX tends to start from the glyph's x + width, not x.
	 */
	var ?advanceX:Float;

	/**
	 * The offset of the glyph from the line's x position and the previous glyph's advanceX. 
     * This will not influence the position of the next glyph.
	 */
	var ?offsetX:Float;

	/**
	 * The offset of the glyph from the baseline. The baseline is the text line's y position.
	 */
	var ?offsetY:Float;
};
