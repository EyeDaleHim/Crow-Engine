package gear.input;

import openfl.display.Stage;
import openfl.events.KeyboardEvent;

class Input
{
    public static final inputPath:String = 'data/config/inputs.json';

    /**
     * Reads an internal input file.
     * @param inputFile 
     */
    public function new(?stage:Stage, inputFile:String)
    {
        if (stage == null)
            stage = FlxG.stage;

        stage.addEventListener(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent)->{

        });

        stage.addEventListener(KeyboardEvent.KEY_UP, (e:KeyboardEvent)->{

        });

        read(inputFile);
    }

    public function read(inputFile:String):Void
    {
        var rawContents = FlxG.assets.getTextUnsafe(inputFile);
        if (rawContents == null)
            return;

        var rawJson = Json.parse(JsonComment.removeComments(rawContents));
    }
}