package states.debug.game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import openfl.display.BitmapData;
import objects.notes.Note;
import backend.graphic.CacheManager;

class ChartEditorState extends MusicBeatState
{
	public static var CELL_SIZE:Int = 40;
    public static var gridTemplate:BitmapData; // for copying

	public static var lastPos:Float = 0.0;

	public var strumLines:Array<FlxTiledSprite> = [];
	public var camFollow:FlxObject;

	override function create()
	{
		Main.fps.alpha = 0.2;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 0.2;

		CacheManager.freeMemory(BITMAP, true);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();

        if (FlxG.sound.music != null)
            FlxG.sound.music.pause();

		Conductor.songPosition = lastPos;

        FlxG.mouse.visible = true;

		if (gridTemplate == null)
			gridTemplate = FlxGridOverlay.createGrid(CELL_SIZE, CELL_SIZE, CELL_SIZE * 2, CELL_SIZE * 2, true,
				0xffdee8eb, 0x88d9d5d5);

		for (i in 0...2)
		{
			var strumLine:FlxTiledSprite = new FlxTiledSprite(gridTemplate, gridTemplate.width * 2, CELL_SIZE);
			strumLine.updateHitbox();
			strumLine.height = (FlxG.sound.music.length / Conductor.stepCrochet) * CELL_SIZE;
            strumLine.x = 50 + ((CELL_SIZE + 8) * (i * 4));

			strumLines.push(strumLine);
			add(strumLine);
		}

		FlxG.camera.follow(camFollow, null, 1);

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.sound.music.time = Conductor.songPosition;

			if (FlxG.sound.music.playing)
				FlxG.sound.music.pause();
			else
				FlxG.sound.music.resume();
		}

		if (!FlxG.sound.music.playing)
		{
			if (FlxG.keys.pressed.UP || FlxG.keys.pressed.DOWN)
			{
				var speed:Float = -1;

				if (FlxG.keys.pressed.DOWN)
					speed *= -1;

				Conductor.songPosition += elapsed * (speed * 1000);

				if (Conductor.songPosition >= FlxG.sound.music.length)
					Conductor.songPosition = 0;
			}
		}
		else
			Conductor.songPosition = FlxG.sound.music.time;

		lastPos = Conductor.songPosition;

		camFollow.y = FlxMath.remapToRange(Conductor.songPosition, 0, FlxG.sound.music.length, strumLines[0].y, strumLines[0].y + strumLines[0].height);

		super.update(elapsed);
	}

	override public function destroy()
	{
		Main.fps.alpha = 1.0;
		@:privateAccess
		for (outline in Main.fps.outlines)
			outline.alpha = 1.0;

		super.destroy();
	}
}
