package mods;

import weeks.WeekHandler;
import mods.ModData;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class ModManager
{
	private static var initialized:Bool = false;

	public static var mods:Array<ModData> = [];

	public static function initalize():Void
	{
		if (!initialized)
		{
			var path:String = 'mods/';

			if (FileSystem.exists(path))
			{
				for (mod in FileSystem.readDirectory(path))
				{
					var modPath = haxe.io.Path.join([path, mod]);
					if (FileSystem.isDirectory(modPath))
					{
						var data:ModData = Json.parse(File.getContent(haxe.io.Path.join([modPath, 'main.json'])));
						data.folderName = mod;

						mods.push(data);
					}
				}
			}

			trace(FileSystem.exists(path));
		}

		for (mod in mods)
		{
			var modWeeks:Array<WeekStructure> = [];

			// find weeks
			var folder:String = ModPaths.getPathAsFolder(mod.folderName, 'data/weeks');
			if (FileSystem.exists(folder))
			{
				var directory:Array<String> = FileSystem.readDirectory(folder);
				directory.remove('songs');
				for (week in directory)
				{
					var filePath:String = ModPaths.data(mod.folderName, 'weeks/$week');

					if (!FileSystem.isDirectory(filePath))
						modWeeks.push(Json.parse(File.getContent(filePath)));
				}

				folder += '/songs';
			}

			for (week in modWeeks)
			{
				week.modParent = mod.folderName;
				WeekHandler.addWeek(week);
			}

			// we don't expect it to appear anyway
			if (FileSystem.exists(folder))
			{
				for (song in FileSystem.readDirectory(folder))
				{
					if (WeekHandler.findSongIndex(song) != -1)
					{
						var songStructure:SongStructure = Json.parse(File.getContent(ModPaths.data(mod.folderName, 'weeks/songs/$song.json')));
						songStructure.modParent = mod.folderName;
						WeekHandler.songs.push(songStructure);
					}
				}
			}
		}
	}
}
