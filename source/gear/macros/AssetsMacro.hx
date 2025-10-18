package gear.macros;

import sys.FileSystem;
import sys.io.File;
#if macro
import haxe.macro.Context;
#end
import haxe.io.Path;

class AssetsMacro
{
	public static macro function getProjectPath():haxe.macro.Expr.ExprOf<String>
	{
		return macro $v{Sys.getCwd()};
	}

	// assets to export folder
	public static macro function buildAssets()
	{
		#if (display || web)
		return macro {};
		#end

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
		var assetFolder:String = Path.join([exportPath, 'assets']);

		FileSystem.createDirectory(assetFolder);

		final directories:Array<String> = [];
		final list:Array<String> = [];

		function addFiles(directory:String)
		{
			for (path in FileSystem.readDirectory(directory))
			{
				var currentPath:String = Path.join([directory, path]);
				if (FileSystem.isDirectory(currentPath))
				{
					directories.push(currentPath);
					addFiles(currentPath);
				}
				else
				{
					list.push(currentPath);
				}
			}
		}

		addFiles('assets');

		#if !ASSETS_PACKAGING
		for (item in directories)
		{
			var exportItemPath:String = Path.join([exportPath, item]);
			FileSystem.createDirectory(exportItemPath);
		}

		for (item in list)
		{
			var exportItemPath:String = Path.join([exportPath, item]);
			File.copy(item, exportItemPath);
		}
		#end

		return macro {};
	}
}
