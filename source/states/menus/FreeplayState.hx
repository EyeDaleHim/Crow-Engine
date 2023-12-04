package states.menus;

import music.Song;
import states.menus.MainMenuState;
import weeks.ScoreContainer;
import weeks.WeekHandler;
import objects.ui.HealthIcon;
import backend.graphic.CacheManager;
import backend.LoadingManager;
#if PRELOAD_ALL
import sys.thread.Thread;
import openfl.utils.Assets;
#end

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

	private static var availableDifficulties:Array<String> = [];

	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = -1;

	private static var savedScore:Float = 0.0;
	private static var savedAccuracy:Float = 0.0;

	private static var lerpingScore:Float = 0.0;
	private static var lerpingAccuracy:Float = 0.0;

	override public function create()
	{
		CacheManager.freeMemory(BITMAP, true);

		background = new FlxSprite(Paths.image("menus/freeplayBG"));
		background.scale.set(1.1, 1.1);
		background.screenCenter();
		background.scrollFactor.set();
		background.antialiasing = Settings.getPref('antialiasing', true);
		add(background);

		scoreBG = new FlxSprite().makeGraphic(Std.int(FlxG.width * 0.35), 75, FlxColor.BLACK);
		scoreBG.alpha = 0.6;
		scoreBG.x = FlxG.width - scoreBG.width;
		scoreBG.antialiasing = Settings.getPref('antialiasing', true);

		scoreText = new FlxText(0, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		scoreText.text = 'PERSONAL BEST: ${Math.floor(savedScore)} (${Tools.formatAccuracy(savedAccuracy)}%)';
		scoreText.x = FlxG.width - scoreText.width - 8;
		// scoreText.centerOverlay(scoreBG, X); might come in handy
		scoreText.antialiasing = Settings.getPref('antialiasing', true);

		diffText = new FlxText(0, scoreText.y + 35, FlxG.width - scoreText.x, "", 26);
		diffText.setFormat(Paths.font("vcr.ttf"), 26, FlxColor.WHITE, CENTER);
		diffText.antialiasing = Settings.getPref('antialiasing', true);
		diffText.centerOverlay(scoreBG, X);

		songList = new FlxTypedGroup<Alphabet>();
		add(songList);

		var len:Int = 0;
		for (song in WeekHandler.songs)
		{
			var songObject:Alphabet = new Alphabet(0, (70 * len) + 30, song.name, true, false);
			songObject.isMenuItem = true;
			songObject.targetY = len;
			songObject.ID = len;
			songList.add(songObject);

			var iconObject:HealthIcon = new HealthIcon(0, 0, song.icon);
			iconObject.ID = songObject.ID;
			iconObject.sprTracker = songObject;
			iconObject.offsetTracker.set(songObject.width + 10, (songObject.height / 2) - (iconObject.height / 2));
			iconArray.push(iconObject);
			add(iconObject);

			// we have no reason to update the sprite's animation if it has one frame
			if (iconObject.animation.curAnim != null && iconObject.animation.curAnim.numFrames <= 1)
				iconObject.animation.curAnim.paused = true;

			var metaData:SongMetadata = new SongMetadata(song.name, Std.int(len + 1), song.difficulties, song.color);
			// metaData.
			metaData.weekName = song.parentWeek;

			songs.push(metaData);

			len++;
		}

		add(scoreBG);
		add(scoreText);
		add(diffText);

		availableDifficulties = songs[curSelected].diffs;
		if (curDifficulty == -1)
			curDifficulty = availableDifficulties.indexOf(WeekHandler.songs[curSelected].defaultDifficulty);

		changeSelection();
		changeDiff();

		updateScore(FlxMath.MAX_VALUE_FLOAT);

		InputHandler.registerControl('BACK', function()
		{
			if (!canPress)
				return;

			canPress = false;
			MusicBeatState.switchState(new MainMenuState());

			if (lastPlayed != '')
			{
				FlxG.sound.music.fadeOut(0.5, 0.0, function(twn)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				});
			}
		});

		InputHandler.registerControl('ACCEPT', function()
		{
			if (!canPress)
				return;

			canPress = false;

			if (Song.currentSong != null)
			{
				if (lastPlayed != Song.currentSong.song)
				{
					CacheManager.clearAudio(Paths.instPath(lastPlayed));
					CacheManager.clearAudio(Paths.vocalsPath(lastPlayed));

					lastPlayed = Song.currentSong.song;
				}
			}

			Paths.currentLibrary = songs[curSelected].weekName;
			PlayState.songDiff = curDifficulty;

			FlxG.sound.music.fadeOut(0.5, 0.0);

			Song.loadSong(songs[curSelected].name.formatToReadable(), availableDifficulties[curDifficulty]);

			LoadingManager.startGame();
		});

		InputHandler.registerControl('UI_LEFT', function()
		{
			if (canPress)
				changeDiff(-1);
		});

		InputHandler.registerControl('UI_RIGHT', function()
		{
			if (canPress)
				changeDiff(1);
		});

		InputHandler.registerControl('UI_UP', function()
		{
			if (canPress)
				changeSelection(-1);
		});

		InputHandler.registerControl('UI_DOWN', function()
		{
			if (canPress)
				changeSelection(1);
		});

		super.create();
	}

	private var currentColor:Int = 0;
	private var canPress:Bool = true;

	// no you dingdong don't judge me
	private static var lastSelected:Int = 0;

	private var lastPlayed:String = '';

	override public function update(elapsed:Float)
	{
		songList.forEachExists(function(txt:Alphabet)
		{
			if (!txt.active)
				txt.updateMenuPosition(elapsed);
		});

		if (idleTime > 2.5)
			playSong();
		else
			idleTime += elapsed;

		updateScore(elapsed);

		background.color = FlxColor.interpolate(background.color, currentColor, FlxMath.bound(elapsed * 1.75, 0, 1));

		super.update(elapsed);
	}

	private var existingSong:Bool = false;
	private var idleTime:Float = 0.0;

	public function playSong(?menu:Bool = false):Void
	{
		#if PRELOAD_ALL
		if (!existingSong)
		{
			var instPath:String = Paths.instPath(songs[curSelected].name.formatToReadable());

			if (menu)
				instPath = Paths.music('freakyMenu');

			if (Assets.exists(instPath))
			{
				existingSong = true;

				CacheManager.setAudio(instPath);

				Thread.create(function()
				{
					if (menu)
						CacheManager.clearAudio(Paths.instPath(songs[curSelected].name.formatToReadable()));
					else
						Paths.inst(songs[curSelected].name.formatToReadable());

					FlxG.sound.music.fadeOut(0.5, 0.0, function(twn)
					{
						FlxG.sound.playMusic(CacheManager.getAudio(instPath), 0.0);
						FlxG.sound.music.fadeIn(1.5, 0.0, 0.8);
					});
				});
			}
		}
		#end
	}

	private function updateScore(elapsed:Float = 1):Void
	{
		var scoreString:String = 'PERSONAL BEST: ';

		lerpingScore = Tools.lerpBound(lerpingScore, savedScore, elapsed * 8.775);
		if (Math.abs(savedScore - lerpingScore) < 10)
			lerpingScore = savedScore;
		scoreString += (lerpingScore > 1000000) ? Tools.shorthandNumber(Math.floor(lerpingScore),
			['K', 'M', 'B']) : FlxStringUtil.formatMoney(Math.floor(lerpingScore), false);

		lerpingAccuracy = Tools.lerpBound(lerpingAccuracy, savedAccuracy, elapsed * 4.775);
		if (Math.abs(savedAccuracy - lerpingAccuracy) <= 0.05)
			lerpingAccuracy = savedAccuracy;
		scoreString += ' (${Tools.formatAccuracy(FlxMath.roundDecimal(lerpingAccuracy * 100, 2))}%)';

		scoreText.text = scoreString;
		scoreText.x = FlxMath.lerp(scoreText.x, FlxG.width - scoreText.width - 8, FlxMath.bound(elapsed * 6.775, 0, 1));

		scoreBG.x = scoreText.x - 8;
		scoreBG.setGraphicSize(Math.max(scoreText.width + 16, (FlxG.width + 20) - scoreText.x), scoreBG.height);
		scoreBG.updateHitbox();

		diffText.centerOverlay(scoreBG, X);
	}

	public function changeSelection(change:Int = 0)
	{
		if (change != 0)
			InternalHelper.playSound(SCROLL, 0.75);

		idleTime = 0;

		lastSelected = curSelected;

		CacheManager.clearAudio(Paths.instPath(songs[lastSelected].name.formatToReadable()));

		curSelected = FlxMath.wrap(curSelected + change, 0, songList.length - 1);

		if (curSelected != lastSelected)
			existingSong = false;

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

			song.active = Math.abs(song.targetY) < 4;
		}

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		currentColor = songs[curSelected].color;

		var songResult = ScoreContainer.getSong(songs[curSelected].name.formatToReadable(), curDifficulty);

		savedScore = songResult.score;
		savedAccuracy = songResult.accuracy;
	}

	public function changeDiff(change:Int = 0)
	{
		if (change != 0)
			InternalHelper.playSound(SCROLL, 0.50);

		curDifficulty = FlxMath.wrap(curDifficulty + change, 0, 2);

		diffText.text = switch (availableDifficulties.length)
		{
			case 0:
				"";
			case 1:
				availableDifficulties[0].toUpperCase();
			case _:
				'< ' + availableDifficulties[curDifficulty].toUpperCase() + ' >';
		}

		diffText.centerOverlay(scoreBG, X);

		changeSelection();
	}
}

class SongMetadata
{
	public var name:String;
	public var weekName:String;
	public var week:Int;
	public var diffs:Array<String>;
	public var color:Int;

	public function new(name:String, week:Int, diffs:Array<String>, color:Int)
	{
		this.name = name;
		this.week = week;
		this.diffs = diffs;
		this.color = color;
	}
}
