package build; // Yeah, I know...

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

import haxe.io.Path;

using StringTools;

/**
 * A script which executes before the game is built.
 */
class Prebuild
{
	static inline final BUILD_TIME_FILE:String = '.build_time';

	static function main():Void
	{
		saveBuildTime();
		recapSource();

	}

	static function saveBuildTime():Void
	{
		var fo:sys.io.FileOutput = File.write(BUILD_TIME_FILE);
		var now:Float = Sys.time();
		fo.writeDouble(now);
		fo.close();
	}

	static function recapSource():Void
	{
		var lines:Int = 0;
		var folderLength:Int = 0;
		var fileLength:Int = 0;

		var readFolder:String->Void = null;
		readFolder = function(name:String)
		{
			for (folder in FileSystem.readDirectory(name))
			{
				var completePath:String = Path.join([name, folder]);
				if (FileSystem.isDirectory(completePath))
				{
					folderLength++;
					readFolder(completePath);
				}
				else
				{
					fileLength++;

					completePath = Path.join([Sys.getCwd(), completePath]);
					var file:FileInput = File.read(completePath, false);

					// gets the content length, not the file length :(
					file.seek(0, SeekBegin);
					lines += file.readAll().toString().trim().split('\n').length;

					file.close();
				}
			}
		};

		readFolder("source");
		readFolder("build");

		var stringBuilder:StringBuf = new StringBuf();
		stringBuilder.add("______ [ SOURCE RECAP ] ______ ");
		stringBuilder.add('\n\n');
		stringBuilder.add('Lines: $lines\n');
		stringBuilder.add('Files: $fileLength\n');
		stringBuilder.add('Folders: $folderLength\n');
		stringBuilder.add('\n');
		stringBuilder.add("______________________________ ");

		Sys.println(stringBuilder.toString());

		stringBuilder = null;
	}
}
