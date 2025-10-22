package gear.utils.parsers;

class JsonComment
{
	/**
	 * Removes single-line and multi-line comments from a string.
	 * This method is safe against removing comment-like sequences inside string literals.
	 * @param text The string to remove comments from.
	 * @return The string with comments removed.
	 */
	public static function removeComments(text:String):String
	{
		var regex = ~/("(\\.|[^"\\])*")|('(\\.|[^'\\])*')|\/\*[\s\S]*?\*\/|\/\/.*/g;
		return regex.replace(text, "");
	}
}
