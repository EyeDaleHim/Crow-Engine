package game;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import objects.notes.Note;
import objects.notes.StrumNote;
import weeks.SongHandler;
import states.PlayState;
import tjson.TJSON as Json;
import sys.FileSystem;
import openfl.Assets;

// temporary haxe file to manage modchart, added this in because we're gonna be trying to support multiple modchart systems
class ModChartManager
{
	public var name:String;
	public var format:String;

	public var strumIDs:Map<String, FlxTypedGroup<StrumNote>>;
	public var noteIDs:FlxTypedGroup<Note>;

	public var data:ModchartData;

	public function new(name:String, ?diffic:Int = 1)
	{
		// if the difficulty of this chart wasn't found, take presume of normal difficulty
		if (FileSystem.exists(Paths.data('modcharts/$name')))
		{
			var diffString:String = SongHandler.PLACEHOLDER_DIFF[Std.int(FlxMath.bound(diffic, 0, 2))];

			for (file in FileSystem.readDirectory(Paths.data('modcharts/$name')))
			{
				if (file.split('-')[1] == '$diffString')
				{
					data = readJSON(name, Json.parse(Assets.getText(file)));
				}
			}
		}
	}

	private function transformValue(variable:String, duration:Float, values:Map<String, Dynamic>):Float
	{
		return 0;
	}

	public static function readJSON(name:String, json:String)
	{
		throw 'Unfinished support';

		switch (name.split('-')[1])
		{
			case 'modcharteditor':
				{
					return null;
				}
		}

		// unknown modchart format, parse the data like normal
		return Json.parse(json);
	}
}

typedef ModchartData =
{
	var name:String;
	var tweenMap:Array<TweenData>;
}

typedef TweenData =
{
	var variable:String;
	var values:Map<String, Dynamic>;
	var ease:String;
	var duration:Float;
	var timeTrigger:Float;
}
