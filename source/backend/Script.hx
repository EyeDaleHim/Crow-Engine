package backend;

import hscript.Parser;
import hscript.Interp;

class Script
{
	// blacklisted classes, this will also blacklist variables of these classes as well
	// also p.s this also includes variables of variables e.g (Application.current.window is not allowed because Application.current is an Application class)
	public static final blacklistedClasses:Array<String> = [];

	// this just means if this variable's class is blacklisted but this variable is whitelisted
	// the script will pass through
	public static final whitelistedVariables:Array<String> = [];
}
