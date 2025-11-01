package crow.logics;

enum abstract ActionScope(String) to String
{
	var GLOBAL = "global";
	var LOCAL = "local";
	var ENTITY = "entity";

    @:from
	public static function fromString(value:String):ActionScope
	{
		return switch ((value ?? "").trim().toLowerCase())
		{
			case "global": GLOBAL;
			case "local": LOCAL;
			case "entity": ENTITY;
			default: null;
		}
	}
}