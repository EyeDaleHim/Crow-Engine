package gear.macros;

import sys.FileSystem;
import sys.io.File;
#if macro
import haxe.macro.Context;
#end
import gear.assets.format.MessagePack;
import haxe.zip.Compress;

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
			#if JSON_TO_MESSAGEPACK
			if (Path.extension(item) == 'json')
			{
				try
				{
					final jsonContent = File.getContent(item);
					final parsedJson = Json.parse(JsonComment.removeComments(jsonContent));
					final msgpBytes = MessagePack.serialize(parsedJson);

					var exportItemPath:String = Path.join([exportPath, item]);
					var msgpPath = Path.withExtension(exportItemPath, 'msgp');
					File.saveBytes(msgpPath, msgpBytes);
				}
				catch (e)
				{
					Context.warning('Failed to convert ${item} to MessagePack: ${e}. Copying original file.', Context.currentPos());

					// stack trace
					for (stackItem in e.stack)
					{
						switch (stackItem)
						{
							case FilePos(s, file, line, col):
								Context.warning('	at ${file}:${line}:${col}', Context.currentPos());
							default:
						}
					}

					var exportItemPath:String = Path.join([exportPath, item]);
					File.copy(item, exportItemPath);
				}
			}
			else
			#end
			{
				var exportItemPath:String = Path.join([exportPath, item]);
				File.copy(item, exportItemPath);
			}
		}
		#end

		return macro {};
	}
}
