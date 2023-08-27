package backend.external;

#if (windows)
@:headerInclude("windows.h")
@:headerInclude("winuser.h")
#end
class ExternalCode
{
	#if (windows)
	@:functionCode('
        SetProcessDPIAware();
    ')
	#end
	public static function registerAsDPICompatible() {}
}