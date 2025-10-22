package gear.utils;

import haxe.ds.StringMap;

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
		var regex = new EReg('("(\\\\.|[^"\\\\])*")|(\'(\\\\.|[^\'\\\\])*\')|(/\\*[\\s\\S]*?\\*/)|(//.*)', "g");

		return regex.map(text, (ereg) -> {
			var match = ereg.matched(0);
			// If the match is a comment (starts with /), return an empty string to remove it.
			// Otherwise, it's a string literal, so return it unchanged.
			if (StringTools.startsWith(match, "/")) {
				return "";
			}
			return match;
		});
	}
}
