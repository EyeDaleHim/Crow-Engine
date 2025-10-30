package crow.assets.metadata.display;

typedef AnimatedFontMetadata =
{
    var glyphs:GlyphMetadata;

    var ?frameRate:Float; // default is 24
    var framesPath:String;
};