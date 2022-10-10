package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import states.menus.MainMenuState;
import weeks.SongHandler;
import objects.HealthIcon;

using utils.Tools;

class FreeplayState extends MusicBeatState
{
	private var songs:Array<SongMetadata> = [];

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

		scoreBG = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.35), 99, FlxColor.BLACK);
		scoreBG.alpha = 0.6;
		scoreBG.setPosition(FlxG.width - scoreBG.width, 0);
		scoreBG.antialiasing = Settings.getPref('antialiasing', true);
		add(scoreBG);

		scoreText = new FlxText(0, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK);
		scoreText.centerOverlay(scoreBG, X);
		scoreText.antialiasing = Settings.getPref('antialiasing', true);
		add(scoreText);

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

			if (i == 0)
				background.color = currentColor = SongHandler.songs['Base_Game'][week.week].color;
			for (song in songsList)
			{
				var j:Int = weekHolder.indexOf(week) + songsList.indexOf(song);

				var songObject:Alphabet = new Alphabet(0, (70 * j) + 30, song, true, false);
				songObject.isMenuItem = true;
				songObject.targetY = i + j;
				songObject.ID = Std.int(i + j);
				songList.add(songObject);

				var iconObject:HealthIcon = new HealthIcon(0, 0, SongHandler.songs['Base_Game'][week.week].icons[songsList.indexOf(song)]);
				iconObject.ID = songObject.ID;
				iconObject.sprTracker = songObject;
				iconArray.push(iconObject);
				add(iconObject);

				songs.push(new SongMetadata(song, Std.int(i + 1), SongHandler.songs['Base_Game'][week.week].color));
			}
		}

		changeSelection();

		super.create();
	}

	private var currentColor:Int = 0;

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE)
			MusicBeatState.switchState(new MainMenuState());

		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		else if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		background.color = FlxColor.interpolate(background.color, currentColor, FlxMath.bound(elapsed * 1.75, 0, 1));

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

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		currentColor = songs[curSelected].color;
	}
}

class SongMetadata
{
	public var name:String;
	public var week:Int;
	public var color:Int;

	public function new(name:String, week:Int, color:Int)
	{
		this.name = name;
		this.week = week;
		this.color = color;
	}
}
