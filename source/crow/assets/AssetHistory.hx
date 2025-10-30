package crow.assets;

import haxe.io.Bytes;
import haxe.EnumTools;
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

	private static final FLX_ASSET_TYPES:Array<FlxAssetType> = [TEXT, IMAGE, SOUND, FONT, BINARY];

	private var data:Bytes;

	public var context(get, never):LoadContext;
	public var type(get, never):FlxAssetType;
	public var caller(get, never):String;
	public var filePath(get, never):String;
	public var timestamp(get, never):Float;

	public function new(context:LoadContext, type:FlxAssetType, caller:String, filePath:String)
	{
		final timestamp = Date.now().getTime() / 1000;

		final callerBytes = Bytes.ofString(caller);
		final filePathBytes = Bytes.ofString(filePath);

		// 8 (timestamp) + 1 (context) + 1 (type) + 2 (caller len) + caller + 2 (path len) + path
		data = Bytes.alloc(8 + 1 + 1 + 2 + callerBytes.length + 2 + filePathBytes.length);
		var pos = 0;

		data.setDouble(pos, timestamp);
		pos += 8;

		data.set(pos++, context.getIndex());
		data.set(pos++, FLX_ASSET_TYPES.indexOf(type, 0));

		data.setUInt16(pos, callerBytes.length);
		pos += 2;

		data.blit(pos, callerBytes, 0, callerBytes.length);
		pos += callerBytes.length;

		data.setUInt16(pos, filePathBytes.length);
		pos += 2;

		data.blit(pos, filePathBytes, 0, filePathBytes.length);

		if (verbose)
		{
			trace(toString());
		}
	}

	private function get_timestamp():Float
		return data.getDouble(0);

	private function get_context():LoadContext
		return EnumTools.createByIndex(LoadContext, data.get(8));

	private function get_type():FlxAssetType
		return FLX_ASSET_TYPES[data.get(9)];

	private function get_caller():String
	{
		final len = data.getUInt16(10);
		return data.getString(12, len);
	}

	private function get_filePath():String
	{
		final callerLen = data.getUInt16(10);
		final pos = 12 + callerLen;
		final len = data.getUInt16(pos);
		return data.getString(pos + 2, len);
	}

	public function toString():String
	{
		return '[${Date.fromTime(get_timestamp() * 1000)}] ${get_context()} - ${get_caller()} - ${get_filePath()}';
	}
}
