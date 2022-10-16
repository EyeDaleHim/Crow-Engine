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
import weeks.ScoreContainer;
import weeks.SongHandler;
import objects.HealthIcon;

using utils.Tools;

class FreeplayState extends MusicBeatState
{
	private var songs:Array<SongMetadata> = [];

	public var background:FlxSprite;

	public var scoreBG:FlxSprite;
	public var scoreText:FlxText;
	public var diffText:FlxText;

	public var songList:FlxTypedGroup<Alphabet>;
	public var iconArray:Array<HealthIcon> = [];

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	private static var score:LerpConstant = {current: 0.0, lerp: 0.0};
	private static var miss:LerpConstant = {current: 0.0, lerp: 0.0};
	private static var accuracy:LerpConstant = {current: 0.0, lerp: 0.0};

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

		scoreText = new FlxText(0, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		scoreText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		scoreText.text = 'PERSONAL BEST: ${Math.floor(score.current)} (${Tools.formatAccuracy(accuracy.current)}%)';
		scoreText.x = FlxG.width - scoreText.width - 8;
		// scoreText.centerOverlay(scoreBG, X); might come in handy
		scoreText.antialiasing = Settings.getPref('antialiasing', true);

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

				songs.push(new SongMetadata(song, Std.int(i + 1), SongHandler.songs['Base_Game'][week.week].diffs,
					SongHandler.songs['Base_Game'][week.week].color));
			}
		}

		add(scoreBG);
		add(scoreText);

		changeSelection();

		super.create();
	}

	private var currentColor:Int = 0;

	override public function update(elapsed:Float)
	{
		if (controls.getKey('BACK', JUST_PRESSED))
			MusicBeatState.switchState(new MainMenuState());

		if (controls.getKey('UI_UP', JUST_PRESSED))
			changeSelection(-1);
		else if (controls.getKey('UI_DOWN', JUST_PRESSED))
			changeSelection(1);

		if (controls.getKey('UI_LEFT', JUST_PRESSED))
			changeDiff(-1);
		else if (controls.getKey('UI_RIGHT', JUST_PRESSED))
			changeDiff(1);

		updateScore();

		background.color = FlxColor.interpolate(background.color, currentColor, FlxMath.bound(elapsed * 1.75, 0, 1));

		super.update(elapsed);
	}

	private function updateScore():Void
	{
		var scoreString:String = 'PERSONAL BEST: ';

		score.current = FlxMath.bound(FlxMath.lerp(score.current, score.lerp, FlxMath.bound(FlxG.elapsed * 4.775, 0, 1)), 0, score.lerp);
		scoreString += Math.floor(score.current);

		accuracy.current = FlxMath.bound(FlxMath.lerp(score.current, score.lerp, FlxMath.bound(FlxG.elapsed * 4.775, 0, 1)), 0, score.lerp);
		scoreString += ' (${Tools.formatAccuracy(accuracy.current)}%)';

		scoreText.text = scoreString;
		scoreText.x = FlxMath.lerp(scoreText.x, FlxG.width - scoreText.width - 8, FlxMath.bound(FlxG.elapsed * 6.775, 0, 1));

		scoreBG.x = scoreText.x - 8;
		scoreBG.setGraphicSize(Std.int(scoreText.width + 16), Std.int(scoreBG.height));
		scoreBG.updateHitbox();
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

		var songResult = ScoreContainer.getSong(songs[curSelected].name, curDifficulty);

		score.lerp = songResult.score;
		miss.lerp = songResult.misses;
		accuracy.lerp = songResult.accuracy;
	}

	public function changeDiff(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.50);

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, 2);

		changeSelection();
	}
}

class SongMetadata
{
	public var name:String;
	public var week:Int;
	public var diffs:Array<String>;
	public var color:Int;

	public function new(name:String, week:Int, diffs:Array<String>, color:Int)
	{
		this.name = name;
		this.week = week;
		this.color = color;
	}
}

typedef LerpConstant =
{
	var current:Float;
	var lerp:Float;
}
