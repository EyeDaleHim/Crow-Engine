package crow.logics;

enum abstract PredicateOperatorCode(String) to String
{
	var EQ = "EQ";
	var NEQ = "NEQ";
	var GT = "GT";
	var LT = "LT";
	var GTE = "GTE";
	var LTE = "LTE";
	var MODULO = "MODULO";

	@:from
	public static function fromString(value:String):PredicateOperatorCode
	{
		if (value == null)
			return null;

		return switch (value.toUpperCase())
		{
			case "EQ", "==", "EQUAL": EQ;
			case "NEQ", "!=", "NOT_EQUAL": NEQ;
			case "GT", ">": GT;
			case "LT", "<": LT;
			case "GTE", ">=": GTE;
			case "LTE", "<=": LTE;
			case "MOD", "MODULO", "%": MODULO;
			default: null;
		}
	}
}
