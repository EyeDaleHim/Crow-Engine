package crow.logics.tools;

enum abstract ActionScope(String) to String
{
	var GLOBAL = "global";
	var LOCAL = "local";
	var ENTITY = "entity";

	@:from
	public static function fromString(value:String):ActionScope
	{
		// Allow any string to act as a scope, but normalize it (trim/lower)
		// to ensure consistency in map lookups.
		return cast (value ?? "global").trim().toLowerCase();
	}
}