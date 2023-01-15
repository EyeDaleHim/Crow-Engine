package utils;

import flixel.input.keyboard.FlxKey;

class InputFormat
{
	public static var allowedBinds:EReg = ~/[a-z]|[A-Z]|[0-9]|~!@#$%^&*()_\\-=+\\[\\]{};:'",.<>\/?\\\\|/g;
	public static var extraAllowed:Array<String> = [
		"PgU", "PgD", "Hm", "End", "Ins", "Esc", "Del", "Bck", "Cap", "Ent", "Shf", "Ctl", "Alt", "Spc", "Up", "Dn", "Lf", "Tab", "Prt"
	];

	public static function matchesInput(input:FlxKey):Bool
	{
		var parsedFormat:String = InputFormat.format(input);

		if (!allowedBinds.match(parsedFormat)) // no? assume we're using keys that we can't define in our regex
		{
			return extraAllowed.contains(parsedFormat);
		}
		else
			return true;

		return false;
	}

	public static function format(id:FlxKey):String
	{
		switch (id)
		{
			case ZERO:
				return "0";
			case ONE:
				return "1";
			case TWO:
				return "2";
			case THREE:
				return "3";
			case FOUR:
				return "4";
			case FIVE:
				return "5";
			case SIX:
				return "6";
			case SEVEN:
				return "7";
			case EIGHT:
				return "8";
			case NINE:
				return "9";
			case PAGEUP:
				return "PgU";
			case PAGEDOWN:
				return "PgD";
			case HOME:
				return "Hm";
			case END:
				return "End";
			case INSERT:
				return "Ins";
			case ESCAPE:
				return "Esc";
			case MINUS:
				return "-";
			case PLUS:
				return "+";
			case DELETE:
				return "Del";
			case BACKSPACE:
				return "Bck";
			case LBRACKET:
				return "[";
			case RBRACKET:
				return "]";
			case BACKSLASH:
				return "\\";
			case CAPSLOCK:
				return "Cap";
			case SEMICOLON:
				return ";";
			case QUOTE:
				return "'";
			case ENTER:
				return "Ent";
			case SHIFT:
				return "Shf";
			case COMMA:
				return ",";
			case PERIOD:
				return ".";
			case SLASH:
				return "/";
			case GRAVEACCENT:
				return "`";
			case CONTROL:
				return "Ctl";
			case ALT:
				return "Alt";
			case SPACE:
				return "Spc";
			case UP:
				return "Up";
			case DOWN:
				return "Dn";
			case LEFT:
				return "Lf";
			case RIGHT:
				return "Rt";
			case TAB:
				return "Tab";
			case PRINTSCREEN:
				return "Prt";
			case NUMPADZERO:
				return "#0";
			case NUMPADONE:
				return "#1";
			case NUMPADTWO:
				return "#2";
			case NUMPADTHREE:
				return "#3";
			case NUMPADFOUR:
				return "#4";
			case NUMPADFIVE:
				return "#5";
			case NUMPADSIX:
				return "#6";
			case NUMPADSEVEN:
				return "#7";
			case NUMPADEIGHT:
				return "#8";
			case NUMPADNINE:
				return "#9";
			case NUMPADMINUS:
				return "#-";
			case NUMPADPLUS:
				return "#+";
			case NUMPADPERIOD:
				return "#.";
			case NUMPADMULTIPLY:
				return "#*";
			default:
		}
		return FlxKey.toStringMap.exists(id) ? FlxKey.toStringMap[id].toLowerCase() : "N/A";
	}
}
