package build;

import sys.FileSystem;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import haxe.io.Path;
import sys.io.Process;

using StringTools;

class Prebuild
{
	static inline final BUILD_TIME_FILE:String = ".build_time";
	static inline final BUILD_NUMBER_FILE:String = ".build_number";

	static function main():Void
	{
		saveBuildNumber();
		saveBuildTime();
		recapSource();
	}

	static function saveBuildNumber():Void
	{
		var buildNumber:Int = 0;
		var repoName:String = "_blank";

		var currentRepoName = getGitRepoName();

		if (FileSystem.exists(BUILD_NUMBER_FILE))
		{
			var fi:FileInput = File.read(BUILD_NUMBER_FILE);
			try
			{
				repoName = fi.readLine();
				buildNumber = fi.readInt16();
			}
			catch (e:Any)
			{
				// File is corrupt or in old format, reset.
				repoName = currentRepoName;
				buildNumber = 0;
			}
			fi.close();
		}

		if (repoName != currentRepoName)
		{
			buildNumber = 0;
		}

		buildNumber++;

		var fo:FileOutput = File.write(BUILD_NUMBER_FILE);
		fo.writeString(currentRepoName + '\n');
		fo.writeInt16(buildNumber);
		fo.close();
	}

	static function getGitRepoName():String
	{
		try
		{
			var p = new sys.io.Process('git', ['config', '--get', 'remote.origin.url']);
			var exitCode = p.exitCode();
			var repoUrl = p.stdout.readAll().toString().trim();
			p.close();

			if (exitCode == 0 && repoUrl.length > 0)
			{
				return repoUrl;
			}
		}
		catch (e:Any)
		{
			// git not found or other error
		}
		return "_blank";
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

		var top5:Array<{filename:String, lines:Int}> = [];

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
					var lineLen:Int = file.readAll().toString().trim().split('\n').length;
					lines += lineLen;

					file.close();

					top5.push({filename: Path.withoutDirectory(completePath), lines: lineLen});
				}
			}
		};

		readFolder("source");

		top5.sort((Obj1:Dynamic, Obj2:Dynamic) -> return byValues(1, Obj1.lines, Obj2.lines));
		top5 = top5.slice(0, 5);

		var stringBuilder:StringBuf = new StringBuf();
		stringBuilder.add(" ______ [ SOURCE RECAP ] ______ ");
		stringBuilder.add('\n\n');
		stringBuilder.add('Lines: $lines\n');
		stringBuilder.add('Files: $fileLength\n');
		stringBuilder.add('Folders: $folderLength\n');
		stringBuilder.add('\n');
		stringBuilder.add(" __________ [ TOP 5 ] _________ ");
		stringBuilder.add('\n\n');
		for (file in top5)
		{
			stringBuilder.add('${top5.indexOf(file) + 1}. ${file.filename}: ${file.lines}\n');
		}
		stringBuilder.add('\n');

		Sys.println(stringBuilder.toString());

		stringBuilder = null;
	}

	public static inline function byValues(Order:Int, Value1:Float, Value2:Float):Int
	{
		var result:Int = 0;

		if (Value1 < Value2)
		{
			result = Order;
		}
		else if (Value1 > Value2)
		{
			result = -Order;
		}

		return result;
	}
}