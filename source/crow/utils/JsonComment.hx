package crow.utils;

/**
 * Utility for handling JSON with comments (JSONC).
 */
@:final
class JsonComment
{
	// Static-only class: hide constructor
	private function new() {}

	/**
	 * Cleans and parses a JSON string containing comments or trailing commas.
	 */
	public static function parse(text:String):Dynamic
	{
		return haxe.Json.parse(strip(text));
	}

	/**
	 * Removes comments and trailing commas, preserving line numbers for error reporting.
	 */
	public static function strip(text:String):String
	{
		return removeTrailingCommas(removeComments(text));
	}

	public static function removeComments(text:String):String
	{
		// Regex handles: "strings", 'strings', /* multi */, and // single
		var regex = new EReg('("(\\\\.|[^"\\\\])*")|(\'(\\\\.|[^\'\\\\])*\')|(/\\*[\\s\\S]*?\\*/)|(//.*)', "g");

		return regex.map(text, (ereg) ->
		{
			var match = ereg.matched(0);
			if (StringTools.startsWith(match, "/"))
			{
				// Replace comment content with spaces to preserve error line offsets
				return ~/./g.map(match, (e) ->
				{
					var c = e.matched(0);
					return (c == "\n" || c == "\r") ? c : " ";
				});
			}
			return match;
		});
	}

	public static function removeTrailingCommas(json:String):String
	{
		return ~/,\s*([\]}])/g.replace(json, "$1");
	}
}
