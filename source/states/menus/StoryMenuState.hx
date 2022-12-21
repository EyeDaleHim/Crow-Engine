package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.util.FlxSort;
import objects.WeekSprite;
import objects.character.WeekCharacter;
import weeks.SongHandler;
import weeks.SongHandler.WeekList;
import states.PlayState;

using utils.Tools;

class StoryMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = Std.int(Math.max(0, SongHandler.PLACEHOLDER_DIFF.indexOf(SongHandler.defaultDifficulty)));

	// fuck you
	public var sortedWeeks:Array<WeekList> = [];
	public var weekDataNames:Array<String> = [];

	public var backgroundBox:FlxSprite;
	public var weekSprites:FlxTypedGroup<WeekSprite>;
	public var difficultySelectors:FlxTypedGroup<FlxSprite>;
	public var characters:Array<WeekCharacter> = [];

	public var diffSprite:FlxSprite;
	public var arrowLeft:FlxSprite;
	public var arrowRight:FlxSprite;

	private var arrowRects:FlxRect;

	override function create()
	{
		backgroundBox = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);

		weekSprites = new FlxTypedGroup<WeekSprite>();
		difficultySelectors = new FlxTypedGroup<FlxSprite>();

		for (key in SongHandler.songs["Base_Game"].keys())
		{
			var weekData:WeekList = SongHandler.getWeek(key);
			sortedWeeks[weekData.index] = weekData;
			weekDataNames[weekData.index] = key;
		}

		sortedWeeks.sort(function(a, b)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.index, b.index);
		});

		for (week in sortedWeeks)
		{
			// sprite
			var weekSprite:WeekSprite = new WeekSprite(0, (week.index * 120) + 480, weekDataNames[week.index]);
			weekSprite.screenCenter(X);
			weekSprite.targetY = weekSprite.ID = Std.int(week.index);
			weekSprite.attributes.set('weekY', 0.0);
			weekSprites.add(weekSprite);
		}

		diffSprite = new FlxSprite(FlxG.width * 0.8, 480);

		var diffs:Array<String> = sortedWeeks[curSelected].diffs;
		if (diffs == null || diffs.length == 0)
			diffs = ['Easy', 'Normal', 'Hard'];

		diffSprite.loadGraphic(Paths.image('menus/storymenu/difficulties/${diffs[Std.int(FlxMath.bound(curDifficulty, 0, diffs.length - 1))].toLowerCase()}'));

		var arrowFrames:FlxAtlasFrames = Paths.getSparrowAtlas('menus/storymenu/menuassets/story_assets');

		arrowLeft = new FlxSprite(weekSprites.members[0].x + weekSprites.members[0].width + 10, weekSprites.members[0].y + 10);
		arrowLeft.frames = arrowFrames;
		arrowLeft.animation.addByPrefix('idle', "arrow left");
		arrowLeft.animation.addByPrefix('press', "arrow push left");
		arrowLeft.animation.play('idle');

		arrowRects = new FlxRect(arrowLeft.x, arrowLeft.y, arrowLeft.width, arrowLeft.height);

		arrowRight = new FlxSprite(arrowLeft.x + 370, arrowLeft.y);
		arrowRight.frames = arrowFrames;
		arrowRight.animation.addByPrefix('idle', "arrow right");
		arrowRight.animation.addByPrefix('press', "arrow push right");
		arrowRight.animation.play('idle');

		arrowRects.union(new FlxRect(arrowRight.x, arrowRight.y, arrowRight.width, arrowRight.height));

		// calling the function from Tools is probably a tad-bit expensive

		diffSprite.setPosition(arrowRects.x
			+ (arrowRects.width / 2)
			- (diffSprite.width / 2),
			arrowRects.y
			+ (arrowRects.height / 2)
			- (diffSprite.height / 2));

		difficultySelectors.add(arrowLeft);
		difficultySelectors.add(arrowRight);

		add(weekSprites);
		add(backgroundBox);
		add(difficultySelectors);
		add(diffSprite);

		changeWeek();

		super.create();
	}

	private var allowControl:Bool = true;
	private var exactWidth:Float = 310;

	override function update(elapsed:Float)
	{
		if (allowControl)
		{
			if (controls.getKey('ACCEPT', JUST_PRESSED))
				acceptWeek();
			else if (controls.getKey('BACK', JUST_PRESSED))
			{
				allowControl = false;
				MusicBeatState.switchState(new states.menus.MainMenuState());
			}
			else
			{
				if (controls.getKey('UI_UP', JUST_PRESSED))
					changeWeek(-1);
				if (controls.getKey('UI_DOWN', JUST_PRESSED))
					changeWeek(1);

				if (controls.getKey('UI_LEFT', JUST_PRESSED))
					changeDiff(-1);
				else if (!controls.getKey('UI_LEFT', PRESSED))
				{
					arrowLeft.animation.play('idle');
					arrowLeft.offset.set(0, 0);
				}
				if (controls.getKey('UI_RIGHT', JUST_PRESSED))
					changeDiff(1);
				else if (!controls.getKey('UI_RIGHT', PRESSED))
				{
					arrowRight.animation.play('idle');
					arrowRight.offset.set(0, 0);
				}
			}
		}

		for (week in weekSprites.members)
		{
			// do this to prevent a barely noticeable visual bug
			week.attributes['weekY'] = Tools.lerpBound(week.attributes['weekY'], (week.targetY * 120) + 480, elapsed * 9.6);
			week.y = Math.max(backgroundBox.y, week.attributes['weekY']);
		}

		diffSprite.y = Math.min(diffSprite.y + (elapsed * 120), arrowRects.y + (arrowRects.height / 2) - (diffSprite.height / 2));
		diffSprite.alpha += elapsed * 4.5;

		super.update(elapsed);
	}

	public function changeWeek(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		curSelected = FlxMath.wrap(Std.int(curSelected + change), 0, sortedWeeks.length - 1);

		var range:Int = 0;

		for (weekSpr in weekSprites.members)
		{
			weekSpr.targetY = range - curSelected;
			range++;

			if (weekSpr.targetY == 0)
			{
				weekSpr.alpha = 1.0;
			}
			else
			{
				weekSpr.alpha = 0.6;
			}
		}

		changeDiff();
	}

	public function changeDiff(change:Int = 0):Void
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.50);

		var lastDiff:Int = curDifficulty;

		var diffs:Array<String> = sortedWeeks[curSelected].diffs;
		if (diffs == null || diffs.length == 0)
			diffs = ['Easy', 'Normal', 'Hard'];

		curDifficulty = FlxMath.wrap(Std.int(curDifficulty + change), 0, diffs.length - 1);

		if (change < 0)
		{
			arrowLeft.animation.play('press');
			arrowLeft.centerOffsets();
		}
		else if (change > 0)
		{
			arrowRight.animation.play('press');
			arrowRight.centerOffsets();
		}

		if (lastDiff != curDifficulty)
		{
			diffSprite.loadGraphic(Paths.image('menus/storymenu/difficulties/${diffs[Std.int(FlxMath.bound(curDifficulty, 0, diffs.length - 1))].toLowerCase()}'));

			diffSprite.alpha = 0.1;
			diffSprite.setPosition(arrowRects.x
				+ (arrowRects.width / 2)
				- (diffSprite.width / 2),
				arrowRects.y
				+ (arrowRects.height / 2)
				- (diffSprite.height / 2)
				- 15);
		}
	}

	public function acceptWeek():Void
	{
		allowControl = false;

		FlxG.sound.play(Paths.sound('menu/confirmMenu'), 0.75);

		weekSprites.members[curSelected].isFlashing = true;

		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			Paths.currentLibrary = weekDataNames[curSelected];

			PlayState.playMode = STORY;
			PlayState.storyPlaylist = sortedWeeks[curSelected].songs;
			PlayState.songDiff = curDifficulty;

			music.Song.loadSong(PlayState.storyPlaylist[0].formatToReadable(), curDifficulty);
			MusicBeatState.switchState(new PlayState());
		});

		for (character in characters)
		{
			if (character.confirmPose != '')
				character._posing = true;
		}
	}
}
