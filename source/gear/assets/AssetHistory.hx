package gear.assets;

import flixel.system.frontEnds.AssetFrontEnd.FlxAssetType;
import Date;

enum LoadContext
{
	IO_SUCCESS;
	CACHE_FETCH;
	FAILURE;
	PERMISSION_DENIED;
}

class AssetHistory
{
    public static var verbose:Bool = (haxe.macro.Compiler.getDefine('debug') == "1") ?? false;

	public var context:LoadContext;
	public var type:FlxAssetType;
	public var caller:String;
	public var filePath:String;
	public var timestamp:Float;

	public function new(context:LoadContext, type:FlxAssetType, caller:String, filePath:String)
	{
		this.context = context;
		this.type = type;
		this.caller = caller;
		this.filePath = filePath;
		this.timestamp = Date.now().getTime() / 1000;

        if (verbose)
        {
            trace(toString());
        }
	}

	public function toString():String
	{
		return '[${Date.fromTime(timestamp * 1000)}] ${context} - ${caller} - ${filePath}';
	}
}
