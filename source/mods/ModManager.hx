package mods;

import mods.ModData;
import openfl.Assets;
import sys.FileSystem;
import haxe.Json;

class ModManager
{
	private static var initialized:Bool = false;

	public static var mods:Array<ModData> = [];

	public static function initalize():Void
	{
		if (!initialized)
		{
            var path:String = 'mods';

			if (FileSystem.exists(path))
			{
				for (mod in FileSystem.readDirectory(path))
				{
                    if (FileSystem.isDirectory('mods/$mod'))
                    {
                        path = 'mods/$mod';
                        if (FileSystem.exists('$path/main.json'))
                        {
                            var data:ModData = Json.parse(Assets.getText('$path/main.json'));
                            data.folderName = mod;

                            mods.push(data);
                        }
                    }
				}
			}

            for (mod in mods)
            {

            }
		}
	}
}
