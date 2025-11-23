package crow.macros;

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
			compressionLevel = -1;
		}
		#end

		var assetsRoot = AssetProcessorMacro.processDir;
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
		var exportPath:String = Path.join(['export', 'builds', #if debug 'debug' #else 'release' #end, target, 'bin']);
		var outputBundleFile = Path.join([exportPath, 'assets.bundle']);
		var outputCacheFile = Path.join([exportPath, cacheFile]);

		// Read Bundle Cache
		var oldCache:Map<String, Float> = new Map<String, Float>();
		if (FileSystem.exists(outputCacheFile))
		{
			try
			{
				oldCache = Unserializer.run(File.getContent(outputCacheFile));
			}
			catch (e:Any) {}
		}

		var files:Map<String, Bytes> = new Map<String, Bytes>();
		var newCache:Map<String, Float> = new Map<String, Float>();
		var isDirty = false;

		function traverse(dir:String)
		{
			if (!FileSystem.exists(dir))
				return;

			for (item in FileSystem.readDirectory(dir))
			{
				// Skip internal processor cache file
				if (item == AssetProcessorMacro.cacheFile)
					continue;

				var fullPath = Path.join([dir, item]);

				// Calculate path relative to the process root (e.g. "data/config.json")
				var relPath = fullPath.substr(assetsRoot.length + 1);
				var normalizedPath = Path.normalize(relPath);

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

					var content = File.getBytes(fullPath);
					files.set(normalizedPath, content);
				}
			}
		}

		traverse(assetsRoot);

		if (Lambda.count(newCache) != Lambda.count(oldCache))
			isDirty = true;

		if (!isDirty && FileSystem.exists(outputBundleFile))
		{
			return fields;
		}

		var fileInfos:Map<String, {size:Int, offset:Int}> = new Map<String, {size:Int, offset:Int}>();
		var currentOffset = 0;

		var filePaths = [for (k in files.keys()) k];

		// Collect Directories for the header
		function addDirs(root:String)
		{
			if (!FileSystem.exists(root))
				return;
			for (dir in FileSystem.readDirectory(root))
			{
				if (dir == AssetProcessorMacro.cacheFile)
					continue;
				var fullPath = Path.join([root, dir]);
				if (FileSystem.isDirectory(fullPath))
				{
					var relPath = fullPath.substr(assetsRoot.length + 1);
					var norm = Path.normalize(relPath);
					fileInfos.set(norm, {size: -1, offset: currentOffset});
					addDirs(fullPath);
				}
			}
		}
		addDirs(assetsRoot);

		filePaths.sort(Reflect.compare);

		var allBytes = [];
		for (path in filePaths)
		{
			var bytes = files.get(path);
			if (compressionLevel != -1)
				bytes = Compress.run(bytes, compressionLevel);

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
				if (currentOffset < (preloadMb * 1024 * 1024))
					haxe.macro.Compiler.define("PRELOAD_ALL_ASSETS");
			}
			catch (e:Any) {}
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

		var outputDir = Path.directory(outputBundleFile);
		if (!FileSystem.exists(outputDir))
			FileSystem.createDirectory(outputDir);

		var out = File.write(outputBundleFile, true);
		out.writeInt32(headerBytes.length);
		out.write(headerBytes);
		out.write(bundleBytes);
		out.close();

		try
		{
			File.saveContent(outputCacheFile, Serializer.run(newCache));
		}
		catch (e:Dynamic) {}
		#end

		return fields;
	}
}
