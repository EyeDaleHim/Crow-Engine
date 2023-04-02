package states.debug.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import openfl.display.BitmapData;
import objects.notes.Note;
import backend.graphic.CacheManager;

class ChartEditorState extends MusicBeatState
{
	public static var CELL_SIZE:Int = 40;
    public static var gridTemplate:BitmapData; // for copying

	public var strumLines:Array<FlxBackdrop> = [];

	override function create()
	{
		CacheManager.freeMemory(BITMAP, true);

		if (gridTemplate == null)
			gridTemplate = FlxGridOverlay.createGrid(CELL_SIZE, CELL_SIZE, Math.floor(4 * CELL_SIZE), Math.floor(16 * CELL_SIZE), true,
				0xffe7e6e6, 0x88d9d5d5);

		for (i in 0...2)
		{
			var strumLine:FlxBackdrop = new FlxBackdrop(gridTemplate, Y);
            strumLine.x = 50 + ((CELL_SIZE + 8) * (i * 4));

			strumLines.push(strumLine);
			add(strumLine);
		}

		super.create();
	}

    public var stepPos:Float = 0.0;

	override public function update(elapsed:Float)
	{
        if (controls.getKey('UI_UP', PRESSED))
            stepPos -= elapsed * 1250;
        else if (controls.getKey('UI_DOWN', PRESSED))
            stepPos += elapsed * 1250;

        for (strumLine in strumLines)
        {
            strumLine.y = -stepPos * 0.35;
        }

		super.update(elapsed);
	}
}
