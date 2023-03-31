#if SCRIPTS_ALLOWED
package mods.states;

import backend.ScriptHandler;
import sys.FileSystem;

class ScriptedState extends MusicBeatState
{
    private var folder:String = '';
    public var scripts:Array<ScriptHandler> = [];

    override public function new(folder:String)
    {
        this.folder = folder;

        super();
    }

    override function create()
    {
        if (folder.length != 0)
        {
            scripts = ScriptHandler.loadListFromFolder(folder);
        }

        callScripts('create', [false]);

        super.create();

        callScripts('create', [true]);
    }

    public function callScripts(func:String, args:Array<Dynamic>):Void
    {
        for (script in scripts)
        {
            if (script.exists(func))
                script.call(func, args);
        }
    }
}
#end