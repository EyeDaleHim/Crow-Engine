package backend.macro;

import haxe.macro.Context;

class Macro
{
	macro public static function initiateMacro()
	{
		#if (haxe_ver < 4.3)
		Context.fatalError('Please use Haxe 4.3.2.', (macro null).pos);
		#end
		return macro
		{}
	}
}
