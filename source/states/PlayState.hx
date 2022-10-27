package states;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import openfl.events.KeyboardEvent;
import states.substates.GameOverSubState;
import states.substates.PauseSubState;
import music.Song;
import objects.HealthIcon;
import objects.Stage;
import objects.Stage.BGSprite;
import objects.character.Character;
import objects.notes.Note;
import objects.notes.StrumNote;

using StringTools;
using utils.Tools;

class CurrentGame
{
	public var score:Int = 0;
	public var misses:Int = 0;

	public var playerHits:Float = 0.0;
	public var playerHitMods:Float = 0.0;

	public var accuracy(get, never):Float;

	public var maxHealth(default, set):Float = 2.0;
	public var health(default, set):Float = 1.0;

	public function new() {}

	function get_accuracy():Float
	{
		return Math.isNaN(playerHits / playerHitMods) ? 0.0 : playerHits / playerHitMods;
	}

	function set_health(v:Float):Float
	{
		return health = Math.min(health, maxHealth);
	}

	function set_maxHealth(v:Float):Float
	{
		health = Math.max(health, v);

		return maxHealth = v;
	}
}

class PlayState extends MusicBeatState
{
	// important variables
	public static var current:PlayState;

	public static var isStoryMode:Bool = false;
	public static var storyPlaylist:Array<String> = [];

	public var gameInfo:CurrentGame;

	// Camera Stuff
	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	public var camFollowObject:FlxObject;
	public var camFollow:FlxPoint;

	// notes
	public var renderedNotes:FlxTypedGroup<Note>;
	public var pendingNotes:Array<Note> = [];

	// characters
	public var playerList:Array<Character> = [];
	public var opponentList:Array<Character> = [];
	public var spectatorList:Array<Character> = [];

	// all of them just refer to the first index in the list
	public var player(get, set):Character;
	public var opponent(get, set):Character;
	public var spectator(get, set):Character;

	// hud stuff
	public var scoreText:FlxText;

	public var healthBar:FlxBar;
	public var healthBarBG:FlxSprite;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var engineText:FlxText;

	function get_player():Character
	{
		return playerList[0];
	}

	function get_opponent():Character
	{
		return opponentList[0];
	}

	function get_spectator():Character
	{
		return spectatorList[0];
	}

	function set_player(char:Character):Character
	{
		return (playerList[0] = char);
	}

	function set_opponent(char:Character):Character
	{
		return (opponentList[0] = char);
	}

	function set_spectator(char:Character):Character
	{
		return (spectatorList[0] = char);
	}

	// stage stuff, will change because this is overly simple
	public var stageData:Stage;

	public var preStageRender:FlxTypedGroup<BGSprite>;
	public var postStageRender:FlxTypedGroup<BGSprite>;

	// simple values to control the game
	public var songStarted:Bool = false;
	public var countdownState:Int = 0; // 0 = countdown not started, 1 = countdown started, 2 = countdown finished
	public var gameEnded:Bool = false;
	public var paused:Bool = false;

	// various internal things
	private var ___trackedSoundObjects:Array<GameSoundObject> = [];
	private var ___trackedTimerObjects:FlxTimerManager = new FlxTimerManager();
	private var ___trackedTweenObjects:Array<FlxTween> = [];

	// used for weeks, load all the songs beforehand instead of loading one individually, limit is 3
	private static var __internalSongCache:Map<String, {music:FlxSound, vocal:FlxSound}> = [];

	private static var _cameraPos:FlxPoint;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		current = this;

		gameCamera = new FlxCamera();
		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;
		pauseCamera = new FlxCamera();
		pauseCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(hudCamera);
		FlxG.cameras.add(pauseCamera);

		FlxCamera.defaultCameras = [gameCamera];

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		gameInfo = new CurrentGame();

		FlxG.mouse.visible = false;

		persistentDraw = true;
		persistentUpdate = true;

		if (Song.currentSong == null)
			Song.loadSong('tutorial', 2);

		if (!PlayState.isStoryMode)
		{
			if (!__internalSongCache.exists(Song.currentSong.song))
			{
				__internalSongCache.set(Song.currentSong.song,
					{music: FlxG.sound.load(Paths.inst(Song.currentSong.song)), vocal: FlxG.sound.load(Paths.vocals(Song.currentSong.song))});
			}
		}

		var stageName:String = 'stage';

		if (Song.currentSong != null)
		{
			stageName = switch (Song.currentSong.song.formatToReadable())
			{
				case 'bopeebo' | 'fresh' | 'dad-battle':
					'stage';
				case 'spookeez' | 'south' | 'monster':
					'spooky';
				case 'pico' | 'philly-nice' | 'blammed':
					'philly';
				case 'satin-panties' | 'high' | 'milf':
					'limo';
				case 'cocoa' | 'eggnog':
					'mall';
				case 'winter-horrorland':
					'mallEvil';
				case 'senpai' | 'roses':
					'school';
				case 'thorns':
					'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					'tank';
				default:
					'stage';
			};
		}

		stageData = Stage.getStage(stageName);

		preStageRender = new FlxTypedGroup<BGSprite>();
		postStageRender = new FlxTypedGroup<BGSprite>();

		var sortedGroup:Array<BGSprite> = [];

		// maps can get unoredred sometimes
		for (bg in stageData.spriteGroup)
		{
			sortedGroup.push(bg);
		}

		if (sortedGroup.length > 1)
		{
			sortedGroup.sort(function(f1, f2)
			{
				return FlxSort.byValues(FlxSort.ASCENDING, f1.ID, f2.ID);
			});
		}

		for (spriteList in sortedGroup)
		{
			switch (spriteList.renderPriority)
			{
				case 0x00:
					preStageRender.add(spriteList);
				case 0x01:
					postStageRender.add(spriteList);
			}
		}

		FlxG.camera.zoom = stageData.defaultZoom;

		add(preStageRender);

		var playerPos = stageData.charPosList.playerPositions;
		var specPos = stageData.charPosList.spectatorPositions;
		var oppPos = stageData.charPosList.opponentPositions;

		player = new Character(playerPos[0].x, playerPos[0].y, 'bf', true);
		player.scrollFactor.set(0.95, 0.95);
		add(player);

		add(postStageRender);

		if (_cameraPos != null)
			_cameraPos.copyTo(camFollow);
		else
			camFollow = new FlxPoint();
		_cameraPos = null;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('game/ui/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		addToHUD(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), gameInfo,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, player.healthColor);
		addToHUD(healthBar);

		scoreText = new FlxText(0, 0, 0, "[Score] 0 // [Misses] 0 // [Rank] (0.00% - N/A)");
		scoreText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.50;
		scoreText.screenCenter(X);
		scoreText.y = healthBarBG.y + 30;
		addToHUD(scoreText);

		initCountdown();

		super.create();
	}

	private function addToHUD(obj:FlxObject, ?group:FlxTypedGroup<FlxBasic> = null)
	{
		if (obj != null)
		{
			obj.cameras = [hudCamera];
			(group == null ? this : group).add(obj);
		}
	}

	private var _lastFrameTime:Int = 0;
	private var _songTime:Float = 0.0;

	override public function update(elapsed:Float)
	{
		if (pendingNotes.length != 0)
		{
			for (note in pendingNotes)
			{
				if (note.strumTime - Conductor.songPosition > 1500)
				{
					break;
				}

				renderedNotes.add(pendingNotes.shift());
			}
		}

		super.update(elapsed);

		FlxG.watch.addQuick('SONG POS', '${Math.round(Conductor.songPosition)}, ($curBeat, $curStep)');

		if (___trackedTimerObjects.active)
			___trackedTimerObjects.update(elapsed);

		if (countdownState != 0)
		{
			if (controls.getKey('PAUSE', JUST_PRESSED))
				openSubState(new PauseSubState());

			Conductor.songPosition += FlxG.elapsed * 1000;

			if (countdownState == 1)
			{
				if (Conductor.songPosition > 0)
				{
					startSong();
					countdownState = 2;
				}
			}

			if (!paused)
			{
				_songTime += (FlxG.game.ticks - _lastFrameTime);
				_lastFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					_songTime = (_songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
	}

	public function initCountdown(?list:Array<String> = null, ?sound:Array<String> = null, ?diff:Int = 1000, ?onProgress:Int->Void = null)
	{
		if (list == null)
			list = ['', 'ready', 'set', 'go'];
		if (sound == null)
			sound = ['3', '2', '1', 'Go'];

		countdownState = 1;

		if (list.length == 0) // ok??? just assume the person wants to start instantly
		{
			Conductor.songPosition = -500;
			if (onProgress != null)
				onProgress(0);
		}
		else
		{
			Conductor.songPosition = -(Conductor.crochet * list.length); // -5000 if the list has 4 things

			for (i in 0...list.length)
			{
				var countdownSpr:FlxSprite = new FlxSprite();
				countdownSpr.visible = false;

				if (list[i] != '')
				{
					countdownSpr = new FlxSprite().loadGraphic(Paths.image('game/countdown/${list[i]}'));
					countdownSpr.visible = true;
					countdownSpr.alpha = 0.0;
					countdownSpr.scrollFactor.set();
					countdownSpr.screenCenter();
					countdownSpr.cameras = [hudCamera];

					add(countdownSpr);
				}

				var countdownSound:GameSoundObject = new GameSoundObject();

				if (sound[i] != '')
				{
					countdownSound.loadEmbedded(Paths.sound('game/countdown/intro-${sound[i]}'));
					countdownSound.onComplete = function()
					{
						FlxG.sound.list.remove(countdownSound);
						___trackedSoundObjects.remove(countdownSound);
					};
					FlxG.sound.list.add(countdownSound);
					___trackedSoundObjects.push(countdownSound);
				}

				new FlxTimer(___trackedTimerObjects).start(Conductor.crochet * i / diff, function(tmr:FlxTimer)
				{
					countdownSpr.alpha = 1.0;

					___trackedTweenObjects.push(FlxTween.tween(countdownSpr, {alpha: 0.0}, Conductor.crochet / diff, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							if (members.indexOf(countdownSpr) >= 0)
								remove(countdownSpr);
							countdownSpr.destroy();
						}
					}));

					if (sound[i] != '')
						countdownSound.play();

					if (onProgress != null)
						onProgress(list.length - i);
				});
			}
		}
	}

	public function startSong():Void
	{
		if (!songStarted)
		{
			songStarted = true;

			@:privateAccess
			{
				FlxG.sound.playMusic(__internalSongCache.get(Song.currentSong.song).music._sound);
			}
		}
	}

	override function openSubState(state:FlxSubState)
	{
		if (Std.isOfType(state, PauseSubState))
		{
			for (sound in ___trackedSoundObjects)
			{
				if (!sound.persistentFromPause)
					sound.pause();
			}

			for (tween in ___trackedTweenObjects)
			{
				if (tween != null)
					tween.active = false;
			}

			___trackedTimerObjects.active = false;

			persistentUpdate = false;
		}

		super.openSubState(state);
	}

	override function closeSubState()
	{
		for (sound in ___trackedSoundObjects)
		{
			if (!sound.persistentFromPause)
				sound.resume();
		}

		for (tween in ___trackedTweenObjects)
		{
			if (tween != null)
				tween.active = true;
		}

		persistentUpdate = true;

		___trackedTimerObjects.active = true;

		super.closeSubState();
	}
}

class GameSoundObject extends FlxSound
{
	public var persistentFromPause:Bool = false;
}
