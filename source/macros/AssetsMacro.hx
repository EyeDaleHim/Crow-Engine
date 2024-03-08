package macros;

import haxe.io.Bytes;
import haxe.io.Path;

class AssetsMacro
{
	private static var cwd:String = Sys.getCwd();
	private static var ignoredExtensions:Array<String> = ['mp3'];

	public static macro function build()
	{
		var exportLocation:String = 'export/';

        #if debug
        exportLocation += 'debug/';
        #elseif release
        exportLocation += 'release/';
        #end

		#if !cpp // what's the define for hl?
		exportLocation += "hl/";
        #elseif windows
        exportLocation += "windows/";
        #elseif mac
        exportLocation += "mac/";
        #elseif linux
        exportLocation += "linux/";   
        #end

        exportLocation += "bin/";

		function embedFile(filePath:String)
		{
			if (!ignoredExtensions.contains(Path.extension(filePath)))
				File.copy(filePath, Path.join([cwd, exportLocation, filePath.substring(cwd.length)]));
		}

		var parentPath = Path.join([cwd, 'assets']);

		function readDirectory(fullPath)
		{
			for (path in FileSystem.readDirectory(fullPath))
			{
				var actual = Path.join([fullPath, path]);

				if (FileSystem.isDirectory(actual))
				{
					if (!FileSystem.exists(Path.join([cwd, exportLocation, actual.substring(cwd.length)])))
						FileSystem.createDirectory(Path.join([cwd, exportLocation, actual.substring(cwd.length)]));
					readDirectory(actual);
				}
				else
					embedFile(actual);
			}
		}

		readDirectory(parentPath);

		return macro
		{};
	}
}
