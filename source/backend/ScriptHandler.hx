#if SCRIPTS_ALLOWED
package backend;

import sys.FileSystem;
import sys.io.File;
import openfl.Assets;

class ScriptHandler extends TeaScript
{
    override public function preset():Void
    {
        super.preset();

		set('FlxG', flixel.FlxG);
		set('FlxBasic', flixel.FlxBasic);
		set('FlxObject', flixel.FlxObject);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxSound', flixel.sound.FlxSound);
		set('FlxSort', flixel.util.FlxSort);
		set('FlxStringUtil', flixel.util.FlxStringUtil);
		set('FlxState', flixel.FlxState);
		set('FlxSubState', flixel.FlxSubState);
		set('FlxText', flixel.text.FlxText);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxTrail', flixel.addons.effects.FlxTrail);

        set('Character', objects.character.Character);
        set('Note', objects.notes.Note);
        set('StrumNote', objects.notes.StrumNote);

        set('PlayState', states.PlayState);
        set('currentGame', states.PlayState.current);

        set('Settings', backend.data.Settings);
        set('Controls', backend.data.Controls);

        set('Tools', utils.Tools);
        set('Paths', utils.Paths);

        set('crowVersion', Main.engineVersion.number);

        #if windows
		set('platform', 'windows');
		#elseif linux
		set('platform', 'linux');
		#elseif mac
		set('platform', 'mac');
		#elseif android
		set('platform', 'android');
		#elseif html5
		set('platform', 'html5');
		#elseif flash
		set('platform', 'flash');
		#else
		set('platform', 'unknown');
		#end		
    }

   // public override function 

    public static function loadListFromFolder(folder:String):Array<ScriptHandler>
    {
        var scriptList:Array<ScriptHandler> = [];
        #if MODS_ENABLED
        var modPath:String = 'mods/scripts/$folder';

        if (FileSystem.exists(modPath))
        {
            for (script in FileSystem.readDirectory(modPath))
            {
                var newScript:ScriptHandler = new ScriptHandler('$modPath/$script');
                TeaScript.global.remove('$modPath/$folder');
                scriptList.push(newScript);
            }
        }
        #end

        var path:String = Paths.getPathAsFolder('scripts/$folder');

        if (FileSystem.exists(path))
        {
            for (script in FileSystem.readDirectory(path))
            {
                var newScript:ScriptHandler = new ScriptHandler('$path/$script');
                TeaScript.global.remove('$path/$script');
                scriptList.push(newScript);
            }
        }

        return scriptList;
    }
}
#end
