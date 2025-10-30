package crow.assets;

import haxe.io.Bytes;
import sys.io.File;
import sys.io.FileInput;
import haxe.Unserializer;
import haxe.io.Path;
import haxe.zip.Uncompress;
import StringTools;

class Bundle
{
	private static inline final HEADER_LENGTH_BYTES = 4; // an Int32 is 4 bytes

	private var fileInfos:Map<String, {size:Int, offset:Int}>;
	private var file:FileInput;
	private var dataOffset:Int;
	private var compressed:Bool;

	private var cache:Map<String, Bytes>;

	private function new(fileInfos:Map<String, {size:Int, offset:Int}>, file:FileInput, dataOffset:Int, compressed:Bool)
	{
		this.fileInfos = fileInfos;
		this.file = file;
		this.dataOffset = dataOffset;
		this.compressed = compressed;
		this.cache = new Map<String, Bytes>();
	}

	public static function load(path:String):Bundle
	{
		var file = File.read(path);
		var headerLength = file.readInt32();
		var headerBytes = file.read(headerLength);
		var headerContent = Uncompress.run(headerBytes).toString();
		var header:Dynamic = Unserializer.run(headerContent);

		var fileInfos:Map<String, {size:Int, offset:Int}> = header.files;
		var compressed:Bool = header.compressed ?? false;

		var dataOffset = HEADER_LENGTH_BYTES + headerLength;

		var bundle = new Bundle(fileInfos, file, dataOffset, compressed);

		#if PRELOAD_ALL_ASSETS
		for (path in fileInfos.keys())
		{
			if (bundle.isDirectory(path))
				continue;
			bundle.cache.set(path, bundle.getBytesUncached(path));
		}
		#end

		return bundle;
	}

	private function getBytesUncached(assetPath:String):Null<Bytes>
	{
		var normalizedPath = Path.normalize(assetPath);
		var info = fileInfos.get(normalizedPath);
		if (info == null)
			return null;

		file.seek(dataOffset + info.offset, sys.io.FileSeek.SeekBegin);
		var bytes = file.read(info.size);

		if (compressed)
		{
			bytes = Uncompress.run(bytes);
		}

		return bytes;
	}

	public function getBytes(assetPath:String):Null<Bytes>
	{
		var normalizedPath = Path.normalize(assetPath);
		if (cache.exists(normalizedPath))
			return cache.get(normalizedPath);

		return getBytesUncached(assetPath);
	}

	public function getString(assetPath:String):Null<String>
	{
		var bytes = getBytes(assetPath);
		if (bytes == null)
		{
			return null;
		}

		return bytes.toString();
	}

	public function exists(assetPath:String):Bool
	{
		var normalizedPath = Path.normalize(assetPath);
		return fileInfos.exists(normalizedPath);
	}

	public function list():Array<String>
	{
		var files = [];
		for (key in fileInfos.keys())
		{
			files.push(key);
		}
		return files;
	}

	public function readDirectory(path:String):Array<String>
	{
		var normalizedPath = Path.normalize(path);
		if (!isDirectory(normalizedPath))
		{
			return [];
		}

		var entries = [];

		var pathWithSlash = normalizedPath;
		if (pathWithSlash != "" && !StringTools.endsWith(pathWithSlash, "/"))
		{
			pathWithSlash += "/";
		}

		for (key in fileInfos.keys())
		{
			if (key == normalizedPath)
			{
				continue;
			}

			if (StringTools.startsWith(key, pathWithSlash))
			{
				var rest = (pathWithSlash == "") ? key : key.substr(pathWithSlash.length);
				if (rest.indexOf("/") == -1 && rest.indexOf("\\") == -1)
				{
					entries.push(rest);
				}
			}
		}
		return entries;
	}

	public function isDirectory(path:String):Bool
	{
		var normalizedPath = Path.normalize(path);
		if (normalizedPath == "") // Treat root as a directory
		{
			return true;
		}

		var info = fileInfos.get(normalizedPath);
		if (info == null)
		{
			return false;
		}

		return info.size == -1;
	}

	public function dispose()
	{
		file.close();
	}
}
