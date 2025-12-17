package crow.macros;

import haxe.macro.Context;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class AssetsMacro
{
	public static macro function getProjectPath():haxe.macro.Expr.ExprOf<String>
	{
		return macro $v{Sys.getCwd()};
	}

	public static macro function buildAssets()
	{
		#if (display || web)
		return macro {};
		#end

		// Only continue if we are NOT bundling.
		// If ASSETS_PACKAGING is true, BundleMacro handles the transfer.
		#if !ASSETS_PACKAGING
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
		var finalAssetsFolder:String = Path.join([exportPath, 'assets']);

		if (!FileSystem.exists(finalAssetsFolder))
		{
			FileSystem.createDirectory(finalAssetsFolder);
		}

		// Copy everything from export/processed_assets -> export/builds/release/windows/bin/assets
		var processedDir = AssetProcessorMacro.processDir;

		function copyRec(dir:String)
		{
			if (!FileSystem.exists(dir))
				return;

			for (file in FileSystem.readDirectory(dir))
			{
				// Skip cache file
				if (file == AssetProcessorMacro.cacheFile)
					continue;

				var srcPath = Path.join([dir, file]);
				var relPath = srcPath.substr(processedDir.length + 1);
				var destPath = Path.join([finalAssetsFolder, relPath]);

				if (FileSystem.isDirectory(srcPath))
				{
					if (!FileSystem.exists(destPath))
						FileSystem.createDirectory(destPath);
					copyRec(srcPath);
				}
				else
				{
					// Simple timestamp check to avoid redundant IO
					if (!FileSystem.exists(destPath)
						|| FileSystem.stat(srcPath).mtime.getTime() > FileSystem.stat(destPath).mtime.getTime())
					{
						File.copy(srcPath, destPath);
					}
				}
			}
		}

		copyRec(processedDir);
		#end

		return macro {};
	}
}
