package backend;

import hscript.Parser;
import hscript.Interp;

class Script
{
	public static final blacklistedClasses:Array<String> = [];
	public static final whitelistedVariables:Array<String> = [];

	// compatibility
	public var definedVersion:Int = Main.engineVersion.number;

	public function new(path:String) {}
}
