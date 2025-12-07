package crow.logics.tools;

enum abstract ActionScope(String) from String to String
{
	var GLOBAL = "global";
	var LOCAL = "local";
	var ENTITY = "entity";

    @:from
	public static function fromString(value:String):ActionScope
	{
		final finalValue = (value ?? "").trim().toLowerCase();
		return switch (finalValue)
		{
			case "global": GLOBAL;
			case "local": LOCAL;
			case "entity": ENTITY;
			default: cast finalValue;
		}
	}
}