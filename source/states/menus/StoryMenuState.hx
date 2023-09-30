package states.menus;

import backend.LoadingManager;
import objects.ui.WeekSprite;
import objects.character.WeekCharacter;
import weeks.WeekHandler;
import states.PlayState;
import backend.graphic.CacheManager;

using utils.Tools;

class StoryMenuState extends MusicBeatState
{
	private var __midPoints:Array<FlxObject> = [];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = -1;

	public static var availableDifficulties:Array<String> = [];

	public var backgroundBox:FlxSprite;
	public var weekSprites:FlxTypedGroup<WeekSprite>;
	public var difficultySelectors:FlxTypedGroup<FlxSprite>;
	public var characters:FlxTypedGroup<WeekCharacter>;

	public var songList:FlxText;
	public var diffSprite:FlxSprite;
	public var arrowLeft:FlxSprite;
	public var arrowRight:FlxSprite;

	private var arrowRects:FlxRect;

	override function create()
	{
		CacheManager.freeMemory(BITMAP, true);

		if (FlxG.sound.music != null &&!FlxG.sound.music.playing)
		{
			FlxG.sound.music.play();
			FlxG.sound.music.volume = 0.6;
		}

		backgroundBox = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);

		for (i in 0...3)
		{
			var midPoint:FlxObject = new FlxObject(0, 0, 1, 1);
			midPoint.centerOverlay(backgroundBox, Y);
			__midPoints.push(midPoint);
			add(midPoint);
		}

		FlxSpriteUtil.space(__midPoints, FlxG.width * 0.15, 0, FlxG.width * 0.35, null, false);

		weekSprites = new FlxTypedGroup<WeekSprite>();
		difficultySelectors = new FlxTypedGroup<FlxSprite>();

		var len:Int = 0;
		for (week in WeekHandler.weeks)
		{
			// sprite
			var weekSprite:WeekSprite = new WeekSprite(0, (len * 120) + 480, week.name);
			weekSprite.screenCenter(X);
			weekSprite.targetY = weekSprite.ID = len;
			weekSprite.attributes.set('weekY', 0.0);
			weekSprites.add(weekSprite);

			len++;
		}

		availableDifficulties = WeekHandler.weeks[0].difficulties;

		characters = new FlxTypedGroup<WeekCharacter>();

		diffSprite = new FlxSprite(FlxG.width * 0.8, 480);

		diffSprite.loadGraphic(Paths.image('menus/storymenu/difficulties/${availableDifficulties[Std.int(FlxMath.bound(curDifficulty, 0, availableDifficulties.length - 1))].toLowerCase()}'));

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

		songList = new FlxText(FlxG.width * 0.05, backgroundBox.y + backgroundBox.height + 50, 0, "TRACKS", 32);
		songList.setFormat(Paths.font("vcr.ttf"), 32, CENTER);
		songList.color = 0xFFe55777;

		add(weekSprites);
		add(backgroundBox);
		add(characters);
		add(songList);
		add(difficultySelectors);
		add(diffSprite);

		availableDifficulties = WeekHandler.weeks[curSelected].difficulties;
		if (curDifficulty == -1)
			curDifficulty = availableDifficulties.indexOf(WeekHandler.songs[curSelected].defaultDifficulty);

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

		for (char in characters.members)
		{
			if (char != null)
			{
				char.centerOverlay(__midPoints[char.ID], XY);
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
			InternalHelper.playSound(SCROLL, 0.75);

		curSelected = FlxMath.wrap(Std.int(curSelected + change), 0, WeekHandler.weeks.length - 1);

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

		var i:Int = 0;
		for (char in WeekHandler.weeks[curSelected].displayCharacters)
		{
			if (char != '')
			{
				var lastFrame:Int = 0;

				if (characters.members[i] != null && characters.members[i].animation.curAnim != null)
					lastFrame = characters.members[i].animation.curAnim.curFrame;
				characters.remove(characters.members[i], true);

				var character:WeekCharacter = new WeekCharacter(0, 0, char);
				character.ID = i;
				character.centerOverlay(__midPoints[character.ID], XY);
				character.animation.play(character.idleList[0], true, false, lastFrame);
				characters.insert(i, character);
			}

			i++;
		}

		songList.text = "TRACKS\n";

		for (song in WeekHandler.weeks[curSelected].songs)
		{
			songList.text += '\n' + song;
		}
		songList.text += '\n';
		songList.text = songList.text.toUpperCase();

		songList.screenCenter(X);
		songList.x -= FlxG.width * 0.35;

		changeDiff();
	}

	public function changeDiff(change:Int = 0):Void
	{
		if (change != 0)
			InternalHelper.playSound(SCROLL, 0.50);

		var lastDiff:Int = curDifficulty;

		var diffs:Array<String> = WeekHandler.weeks[curSelected].difficulties;

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

		InternalHelper.playSound(CONFIRM, 0.75);
		weekSprites.members[curSelected].isFlashing = true;

		for (character in characters.members)
		{
			if (character.animation.curAnim != null)
			{
				if (character.confirmPose != '')
				{
					character.animation.finishCallback = null;
					character.animation.play(character.confirmPose, true);
				}
			}
		}

		new FlxTimer().start(1.5, function(tmr:FlxTimer)
		{
			Paths.currentLibrary = WeekHandler.weeks[curSelected].name;

			PlayState.playMode = STORY;

			var tempArray:Array<String> = [];
			for (song in 0...WeekHandler.weeks[curSelected].songs.length)
			{
				tempArray.push(WeekHandler.weeks[curSelected].songs[song]);
			}

			PlayState.storyPlaylist = tempArray;
			PlayState.songDiff = curDifficulty;

			music.Song.loadSong(PlayState.storyPlaylist[0].formatToReadable(), availableDifficulties[curDifficulty]);
			MusicBeatState.switchState(new PlayState());
		});

		for (character in characters)
		{
			if (character.confirmPose != '')
				character._posing = true;
		}
	}
}
