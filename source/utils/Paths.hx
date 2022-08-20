package utils;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths {
	inline static public var SOUND_EXT:String = #if web 'mp3' #else 'ogg' #end;

    // Helper variable for getting files
    public static var manifest:Map<String, {file:String, library:String}> = [];

    // List of libraries
	public static var libraries:Array<String> = ['shared', 'week1', 'week2', 'week3', 'week4', 'week5', 'week6', 'week7'];

    private static var hasInit:Bool = false;

    // Initalizes saving the manifest for performance
    public static function init()
    {
        if (hasInit)
            return;

        hasInit = true;

        try
        {
            var manifestSave:FlxSave = new FlxSave();
            manifestSave.bind('manifest', 'crow-engine');
            if (manifestSave.data.manifest != null)
                manifest = manifestSave.data.manifest;
        }
        catch (e)
        {
            // Assume the manifest savefile is broken
            manifest = [];
        }
        
        FlxG.stage.application.onExit.add(function(_)
        {
            var manifestSave:FlxSave = new FlxSave();
            manifestSave.bind('manifest', 'crow-engine');
            manifestSave.data.manifest = manifest;

            manifestSave.close();
        });
    }

    // format manifesting
    private static function resolveManifest(file:String = '', ?library:String = null):String
    {
        var middle:String = '-';

        if (library == null || (library != null && library == ''))
        {
            library = '';
            middle = '';
        }

        if (file == null)
            file = '';

        return library + middle + file;
    }

    // format paths
    private static function formatPath(info:{file:String, library:String})
    {
        if (info.library != null && info.library != '')
            return 'assets/libraries/${info.library}/${info.file}';
        return 'assets/${info.file}';
    }

    /*
    * The getPath() function is relatively simple.
    * It checks if the file exists assuming `library = null`,
    * If so, then it scans every library it can to locate which.
    * After finding the file, it starts a process of putting the path into a manifest state,
    * Which will then be used as reference to prevent scanning the library again.
    */
    public static function getPath(file:String = '', ?library:String = null):String
    {
        var preload:String = getPreloadPath(file);

        if (library == null)
        {
            if (OpenFlAssets.exists(preload, IMAGE))
            {
                return formatPath(manifest.get(resolveManifest(file, '')));
            }
            else
            {
                for (libFolder in libraries)
                {
                    var folder:String = getPath(file, libFolder);
                    if (OpenFlAssets.exists(folder))
                    {
                        return formatPath(manifest.get(resolveManifest(file, library)));
                    }
                }
            }
        }

        if (!manifest.exists(resolveManifest(file, library)))
            manifest.set(resolveManifest(file, library), {file: file, library: library});

        return formatPath(manifest.get(resolveManifest(file, library)));
    }

    public static function getPreloadPath(file:String = ''):String
    {
        if (!manifest.exists(resolveManifest(file, '')))
            manifest.set(resolveManifest(file, ''), {file: file, library: ''});
        
        return formatPath(manifest.get(resolveManifest(file, '')));
    }

    public static function image(file:String, ?library:String = null):String
    {
        return getPath('images/${file}.png', library);
    }

    public static function inst(song:String, ?library:String = null):String
    {
        return getPath('data/${song}/Inst.$SOUND_EXT', library);
    }
    
    public static function vocals(song:String, ?library:String = null):String
    {
        return getPath('data/${song}/Voice.$SOUND_EXT', library);
    }

    public static function music(song:String):String
    {
        return getPreloadPath('music/${song}.$SOUND_EXT');
    }

    public static function data(file:String):String
    {
        return getPreloadPath('data/${file}.json');
    }

    public static function file(file:String, end:String, ?library:String = null):String
    {
        return getPath('$file.$end', library);
    }

    public static function getSparrowAtlas(file:String, ?library:String = null):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow(image(file), OpenFlAssets.getText(Paths.file('images/$file', 'xml', library)));
    }
}
