package crow.assets.metadata.helpers;

import flixel.util.typeLimit.OneOfTwo;

/**
 * A type definition for a string that can either be a direct string or a translation key-value pair.
 * 
 * If it is just a String, then it is assumed to be the direct string to be used.
 */
@:forward
abstract TranslatableString(OneOfTwo<String, TranslatePair>) from String from TranslatePair to OneOfTwo<String, TranslatePair>
{
    public function getString():String
    {
        if (Std.isOfType(this, String))
        {
            return this;
        }
        else
        {
            final pair:TranslatePair = this;
            // TODO: Implement actual translation logic here.
            return pair.key;
        
        }
    }
}

typedef TranslatePair =
{
    /**
     * The key to use for translation.
     * 
     * If the key is not found, the game will use this key to
     * represent the output as fallback.
     */
    var key:String;

    /**
     * An optional map of key-value pairs for string replacements within the translated string.
     * 
     * Example:
     * * Input: "dialog_1" -> "Hello {name}" ("key": "dialog_1", "replacements": {"name": "John"}})
     * * Output: "Hello {name}" -> "Hello John"
     */
    var ?replacements:Dynamic<TranslatableString>; 
}