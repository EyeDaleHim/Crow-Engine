package gear.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.zip.Compress;

class BundleMacro
{
	public static macro function build():Array<Field>
	{
		var fields = Context.getBuildFields();

		#if (display || web)
		return fields;
		#end

		#if ASSETS_PACKAGING
		var compressionLevel:Int = -1;
		#if ASSETS_PACKAGING_COMPRESSION
		var compLevelString = Context.definedValue("ASSETS_PACKAGING_COMPRESSION");
		try
		{
			compressionLevel = Std.parseInt(compLevelString);
		}
		catch (e:Any)
		{
			Context.warning("Could not parse ASSETS_PACKAGING_COMPRESSION value, disabling compression.", Context.currentPos());
			compressionLevel = -1;
		}
		#end

		var assetsRoot = "assets";
		var cacheFile = ".bundle_cache";

		var target:String = Context.definedValue('target.name');
		if (target == 'cpp')
		{
			#if windows
			target = 'windows';
			#elseif mac
			target = "mac";
			#elseif linux
			target = "linux";
			#end
		}
		var exportPath:String = Path.join(['export', #if debug 'debug' #else 'release' #end, target, 'bin']);
		var outputBundleFile = Path.join([exportPath, 'assets.bundle']);
		var outputCacheFile = Path.join([exportPath, cacheFile]);

		// Read cache
		var oldCache:Map<String, Float> = new Map<String, Float>();
		if (FileSystem.exists(outputCacheFile))
		{
			try
			{
				var content = File.getContent(outputCacheFile);
				oldCache = Unserializer.run(content);
			}
			catch (e:Any)
			{
				Context.warning("Could not read bundle cache file.", Context.currentPos());
			}
		}

		var files:Map<String, Bytes> = new Map<String, Bytes>();
		var newCache:Map<String, Float> = new Map<String, Float>();
		var isDirty = false;

		function traverse(dir:String)
		{
			for (item in FileSystem.readDirectory(dir))
			{
				var fullPath = Path.join([dir, item]);
				var normalizedPath = Path.normalize(fullPath);
				if (FileSystem.isDirectory(fullPath))
				{
					traverse(fullPath);
				}
				else
				{
					var modTime = FileSystem.stat(fullPath).mtime.getTime();
					newCache.set(normalizedPath, modTime);

					if (!oldCache.exists(normalizedPath) || oldCache.get(normalizedPath) != modTime)
					{
						isDirty = true;
					}

					var content = File.getBytes(normalizedPath);
					files.set(normalizedPath, content);
				}
			}
		}

		traverse(assetsRoot);

		if (Lambda.count(newCache) != Lambda.count(oldCache))
		{
			isDirty = true;
		}

		if (!isDirty)
		{
			return fields;
		}

		var fileInfos:Map<String, {size:Int, offset:Int}> = new Map<String, {size:Int, offset:Int}>();
		var currentOffset = 0;

		// Get file paths and sort them to ensure a consistent bundle layout
		var filePaths = [];
		for (path in files.keys())
		{
			filePaths.push(path);
		}

		function addDirs(root:String)
		{
			for (dir in FileSystem.readDirectory(root))
			{
				var fullPath = Path.join([root, dir]);
				if (FileSystem.isDirectory(fullPath))
				{
					fileInfos.set(fullPath, {size: -1, offset: currentOffset});
					addDirs(fullPath);
				}
			}
		}
		addDirs(assetsRoot);

		filePaths.sort(Reflect.compare);

		// Build file information and byte array in sorted order
		var allBytes = [];
		for (path in filePaths)
		{
			var bytes = files.get(path);

			if (compressionLevel != -1)
			{
				bytes = Compress.run(bytes, compressionLevel);
			}

			var size = bytes.length;
			fileInfos.set(path, {size: size, offset: currentOffset});
			currentOffset += size;
			allBytes.push(bytes);
		}

		var bundleBytes = Bytes.alloc(currentOffset);
		var currentPosition = 0;
		for (bytes in allBytes)
		{
			bundleBytes.blit(currentPosition, bytes, 0, bytes.length);
			currentPosition += bytes.length;
		}

		#if PRELOAD_ALL_ASSETS_VALUE
		var preloadAllAssetsValue = Context.definedValue("PRELOAD_ALL_ASSETS_VALUE");
		if (preloadAllAssetsValue != null)
		{
			try
			{
				var preloadMb = Std.parseInt(preloadAllAssetsValue);
				var preloadBytes = preloadMb * 1024 * 1024;
				if (currentOffset < preloadBytes)
				{
					haxe.macro.Compiler.define("PRELOAD_ALL_ASSETS");
				}
			}
			catch (e:Any)
			{
				Context.warning("Could not parse PRELOAD_ALL_ASSETS_VALUE.", Context.currentPos());
			}
		}
		#end

		var header = {
			files: fileInfos,
			size: currentOffset,
			compressed: compressionLevel != -1
		};

		var serializedHeader = Serializer.run(header);
		var headerBytes = Bytes.ofString(serializedHeader);
		headerBytes = Compress.run(headerBytes, 9);

		// Create directory if it doesn't exist
		var outputDir = Path.directory(outputBundleFile);
		if (!FileSystem.exists(outputDir))
		{
			FileSystem.createDirectory(outputDir);
		}

		var out = File.write(outputBundleFile, true);
		out.writeInt32(headerBytes.length);
		out.write(headerBytes);
		out.write(bundleBytes);
		out.close();

		// Write new cache
		try
		{
			var serializedCache = Serializer.run(newCache);
			File.saveContent(outputCacheFile, serializedCache);
		}
		#end

		return fields;
	}
}
