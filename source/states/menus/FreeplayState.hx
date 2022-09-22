package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import states.menus.MainMenuState;
import weeks.SongHandler;
import objects.HealthIcon;

class FreeplayState extends MusicBeatState
{
	public var background:FlxSprite;

	public var scoreBG:FlxSprite;
	public var scoreText:FlxText;

	public var songList:FlxTypedGroup<Alphabet>;
	public var iconArray:Array<HealthIcon> = [];

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	override public function create()
	{
		background = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/freeplayBG"));
		background.scale.set(1.1, 1.1);
		background.screenCenter();
		background.scrollFactor.set();
		background.antialiasing = Settings.getPref('antialiasing', true);
		add(background);

		// bro using them map.keys() is unordered i have to manually sort them AAAAA
		var weekHolder:Array<{index:Int, week:String}> = [];

		for (week in SongHandler.songs['Base_Game'].keys())
		{
			weekHolder.push({index: SongHandler.songs['Base_Game'][week].index, week: week});
		}

		weekHolder.sort(function(a, b)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.index, b.index);
		});

		songList = new FlxTypedGroup<Alphabet>();
		add(songList);

		for (week in weekHolder)
		{
			var i:Int = songList.length;

			var songsList:Array<String> = SongHandler.songs['Base_Game'][week.week].songs;
			for (song in songsList)
			{
				var j:Int = weekHolder.indexOf(week) + songsList.indexOf(song);

				var songObject:Alphabet = new Alphabet(0, (70 * j) + 30, song, true, false);
				songObject.isMenuItem = true;
				songObject.targetY = i + j;
				songObject.ID = Std.int(i + j);

				songList.add(songObject);
			}
		}

		changeSelection();

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			FlxG.switchState(new MainMenuState());

		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		curSelected = FlxMath.wrap(curSelected + change, 0, songList.length - 1);

		var range:Int = 0; 

		for (song in songList)
		{
			song.targetY = range - curSelected;
			range++;

			if (song.targetY == 0)
			{
				song.alpha = 1.0;

			}
			else
			{
				song.alpha = 0.6;
			}
		}
	}
}

class SongMetadata
{
	public var name:String;
	public var week:Int;
	public var color:Int;
	public var bpm:Float;
	public var folder:String;

	public function new(name:String, week:Int, color:Int, bpm:Int, folder:String)
	{
		this.name = name;
		this.week = week;
		this.color = color;
		this.bpm = bpm;
		this.folder = folder;
	}
}
