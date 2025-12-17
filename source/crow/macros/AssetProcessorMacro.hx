package crow.macros;

import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;
import crow.assets.format.MessagePack;
import crow.utils.JsonComment;
import sys.io.Process;

typedef ProcessorCache =
{
	var defines:Map<String, String>;
	var files:Map<String, Float>; // Path -> Modification Time
}

class AssetProcessorMacro
{
	public static var sourceDir:String = "assets";
	public static var processDir:String = "processed_assets";
	public static var cacheFile:String = ".processor_cache";

	// Defines that affect asset processing. If these change, we rebuild everything.
	static final CRITICAL_DEFINES = ["JSON_TO_MESSAGEPACK", "SBS_SPARROW", "USE_TEXTURE"];

	public static macro function run():haxe.macro.Expr.ExprOf<Void>
	{
		#if (display || web)
		return macro {};
		#end

		if (!FileSystem.exists(processDir))
		{
			FileSystem.createDirectory(processDir);
		}

		var cachePath = Path.join([processDir, cacheFile]);
		var cache:ProcessorCache = {
			defines: new Map<String, String>(),
			files: new Map<String, Float>()
		};

		// Load Cache
		if (FileSystem.exists(cachePath))
		{
			try
			{
				cache = Unserializer.run(File.getContent(cachePath));
			}
			catch (e:Dynamic)
			{
				Context.warning("Corrupted asset processor cache, rebuilding.", Context.currentPos());
			}
		}

		// Check Critical Defines
		var definesChanged = false;
		for (def in CRITICAL_DEFINES)
		{
			var val = Context.definedValue(def);
			if (val == null)
				val = Context.defined(def) ? "1" : "0";

			if (!cache.defines.exists(def) || cache.defines.get(def) != val)
			{
				definesChanged = true;
				cache.defines.set(def, val);
			}
		}

		// If defines changed, wipe the directory to ensure clean state
		if (definesChanged)
		{
			Context.warning("Asset processing flags changed. Rebuilding processed assets...", Context.currentPos());
			cleanDirectory(processDir);
			FileSystem.createDirectory(processDir);
			cache.files = new Map<String, Float>();
		}

		// Process Files
		var filesProcessed = 0;

		function processRec(dir:String)
		{
			if (!FileSystem.exists(dir))
				return;

			for (file in FileSystem.readDirectory(dir))
			{
				var fullPath = Path.join([dir, file]);
				var relPath = fullPath.substr(sourceDir.length + 1); // Relative to assets/

				if (FileSystem.isDirectory(fullPath))
				{
					var targetSubDir = Path.join([processDir, relPath]);
					if (!FileSystem.exists(targetSubDir))
						FileSystem.createDirectory(targetSubDir);
					processRec(fullPath);
				}
				else
				{
					// Check Modification Time
					var mtime = FileSystem.stat(fullPath).mtime.getTime();
					if (cache.files.exists(relPath) && cache.files.get(relPath) == mtime)
					{
						continue; // Skip, unchanged
					}

					if (processFile(fullPath, relPath))
					{
						cache.files.set(relPath, mtime);
						filesProcessed++;
					}
				}
			}
		}

		processRec(sourceDir);

		// Save Cache
		if (filesProcessed > 0 || definesChanged)
		{
			// Context.info('Processed $filesProcessed assets.', Context.currentPos());
			File.saveContent(cachePath, Serializer.run(cache));
		}

		return macro {};
	}

	#if macro
	static function processFile(sourcePath:String, relPath:String):Bool
	{
		var ext = Path.extension(sourcePath).toLowerCase();
		var targetPath = Path.join([processDir, relPath]);

		try
		{
			// JSON -> MessagePack
			#if JSON_TO_MESSAGEPACK
			if (ext == 'json')
			{
				try
				{
					var content = File.getContent(sourcePath);
					var json = Json.parse(JsonComment.removeComments(content));
					var bytes = MessagePack.serialize(json);

					var outPath = Path.withExtension(targetPath, 'msgp_j');
					File.saveBytes(outPath, bytes);
					return true;
				}
				catch (e:Dynamic)
				{
					Context.warning('MsgPack conversion failed for $relPath: $e. Using raw JSON.', Context.currentPos());
					// Fallthrough to copy
				}
			}
			#end
			// XML/PNG -> SBS
			#if SBS_SPARROW
			if (ext == 'xml')
			{
				var pngPath = Path.withExtension(sourcePath, 'png');
				if (FileSystem.exists(pngPath))
				{
					try
					{	
						var xmlContent = File.getContent(sourcePath);
						var textureBytes:haxe.io.Bytes = null;

						// Attempt ATF conversion if USE_TEXTURE is defined
						#if USE_TEXTURE
						final texConvPath = #if windows "tools/png2atf.exe" #else "tools/png2atf" #end;
						if (!FileSystem.exists(texConvPath))
						{
							Context.warning('png2atf.exe not found at "' + texConvPath + '", skipping ATF compression for $relPath. Using raw PNG.', Context.currentPos());
						}
						else
						{
							// The targetPath already includes the processDir and relative path structure.
							// We want the temporary ATF file to be in the same relative location within processDir.
							final tempAtfPath = Path.withExtension(targetPath, "atf");

							var args = [
								"-c d",
								"-r",
								"-f DXT5",
								"-n 0,0",
								"-i",
								pngPath, // Input is the original PNG
								"-o",
								tempAtfPath // Output to temp ATF
							];
							var proc = new Process(texConvPath, args);

							var stdout = proc.stdout.readAll().toString();
							var stderr = proc.stderr.readAll().toString();

							var exit = proc.exitCode(true);
							proc.close();

							if (exit != 0)
							{
								Context.warning('png2atf failed for $relPath: exit=' + exit + ' stdout=' + stdout + ' stderr=' + stderr + '. Using raw PNG.', Context.currentPos());
							}
							else if (!FileSystem.exists(tempAtfPath))
							{
								Context.warning('png2atf succeeded for $relPath but ATF not found at ' + tempAtfPath + ' stdout=' + stdout + ' stderr=' + stderr + '. Using raw PNG.', Context.currentPos());
							}
							else
							{
								// ATF conversion successful, use ATF bytes
								textureBytes = File.getBytes(tempAtfPath);
								FileSystem.deleteFile(tempAtfPath); // Clean up temporary ATF file
							}
						}
						#end

						if (textureBytes == null) {
							// If ATF conversion failed or not attempted, use PNG bytes
							textureBytes = File.getBytes(pngPath);
						}
						// BinarySparrow.fromXML will now receive either PNG bytes or ATF bytes
						var sbsBytes = crow.assets.format.BinarySparrow.fromXML(xmlContent, textureBytes);

						var outPath = Path.withExtension(targetPath, 'sbs');
						File.saveBytes(outPath, sbsBytes);

						return true;
					}
					catch (e:Dynamic)
					{
						Context.warning('SBS conversion failed for $relPath: $e. Using raw XML/PNG.', Context.currentPos());
						// Fallthrough to copy
					}
				}
			}
			// If it is the PNG that belongs to an XML, and we are in SBS mode,
			// we skip copying the PNG because it's embedded in the SBS generated above.
			if (ext == 'png')
			{
				var xmlPath = Path.withExtension(sourcePath, 'xml');
				if (FileSystem.exists(xmlPath))
				{
					// It will be processed when the loop hits the XML.
					// However, we need to mark it as processed in cache so we don't check it again.
					return true;
				}
			}
			#end

			// Default: Copy
			File.copy(sourcePath, targetPath);
			return true;
		}
		catch (e:Dynamic)
		{
			Context.warning('Failed to process $relPath: $e', Context.currentPos());
			return false;
		}
	}

	static function cleanDirectory(dir:String)
	{
		for (file in FileSystem.readDirectory(dir))
		{
			var path = Path.join([dir, file]);
			if (FileSystem.isDirectory(path))
			{
				cleanDirectory(path);
				FileSystem.deleteDirectory(path);
			}
			else
			{
				FileSystem.deleteFile(path);
			}
		}
	}
	#end
}
