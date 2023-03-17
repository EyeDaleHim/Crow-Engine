package states;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxTimer.FlxTimerManager;
import flixel.util.FlxSort;
import flixel.util.FlxPool;
import flixel.util.FlxDestroyUtil;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import game.SkinManager;
import game.cutscenes.CutsceneHandler;
import game.cutscenes.DialogueBox;
import openfl.events.KeyboardEvent;
import states.substates.GameOverSubState;
import states.substates.PauseSubState;
import music.Song;
import music.EventManager;
import objects.HealthIcon;
import objects.Stage;
import objects.Stage.BGSprite;
import objects.ComboSprite;
import objects.stageParts.TankmenUnit;
import objects.character.Character;
import objects.notes.Note;
import objects.notes.Note.NoteRenderer;
import objects.notes.StrumNote;
import utils.CacheManager;
import weeks.ScoreContainer;
import weeks.SongHandler;
import backend.Transitions;
import backend.query.ControlQueries;

using StringTools;
using utils.Tools;

class CurrentGame
{
	public static var RANK_LIST:Array<{accuracy:Float, rank:String}> = [
		{accuracy: 1, rank: 'S'},
		{accuracy: 0.98, rank: 'A+'},
		{accuracy: 0.97, rank: 'A'},
		{accuracy: 0.945, rank: 'B+'},
		{accuracy: 0.9, rank: 'B'},
		{accuracy: 0.875, rank: 'C'},
		{accuracy: 0.665, rank: 'D'},
		{accuracy: 0.5, rank: 'F'},
		{accuracy: 0.0, rank: 'F-'}
	];

	public static var weekScores:Array<SongScore> = [];

	public var rank(get, never):String;

	function get_rank():String
	{
		if (misses <= 0)
		{
			if (judgementList['bad'] > 0 || judgementList['shit'] > 0)
				return 'FC';
			if (judgementList['good'] > 0)
				return 'GFC';
			if (judgementList['sick'] > 0)
				return 'MFC';
		}

		var savedAcc:Float = get_accuracy();

		if (savedAcc == 0)
			return 'N/A';
		else if (savedAcc == 1)
			return 'S+';
		else
		{
			for (i in 0...RANK_LIST.length)
			{
				if (savedAcc >= RANK_LIST[i].accuracy)
				{
					return RANK_LIST[i].rank;
				}
			}
		}

		return 'N/A';
	}

	public var score:Int = 0;
	public var misses:Int = 0;

	public var playerHits:Float = 0.0;
	public var playerHitMods:Float = 0.0;

	public var combo:Int = 0;

	public var accuracy(get, never):Float;

	public var maxHealth:Float = 2.0;
	public var health(default, set):Float = 1.0;

	public var judgements:Array<{judge:String, diff:Float}> = [
		{judge: 'sick', diff: 45},
		{judge: 'good', diff: 90},
		{judge: 'bad', diff: 135},
		{judge: 'shit', diff: 166}
	];

	public var judgementList:Map<String, Int> = ['sick' => 0, 'good' => 0, 'bad' => 0, 'shit' => 0];

	public function judgeNote(rate:Float = 0):
		{
			judge:String,
			diff:Float
		}
	{
		for (i in 0...judgements.length)
		{
			if (FlxMath.roundDecimal(Math.abs(rate), 2) <= judgements[i].diff)
				return judgements[i];
		}

		return {judge: 'miss', diff: FlxMath.MAX_VALUE_FLOAT}; // a miss??? this shouldn't be really possible btw
	}

	public function new()
	{
	}

	function get_accuracy():Float
	{
		return Math.isNaN(playerHits / playerHitMods) ? 0.0 : playerHits / playerHitMods;
	}

	function set_health(v:Float):Float
	{
		return Math.isNaN(v) ? (health = 1) : health = FlxMath.bound(v, 0, maxHealth);
	}
}

class PlayState extends MusicBeatState
{ // important variables
	public static var current:PlayState;
	public static var globalAttributes:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static var playMode:PlayingMode = FREEPLAY;
	public static var storyPlaylist:Array<String> = [];
	public static var songDiff:Int = 1;

	public var gameInfo:CurrentGame;

	// Camera Stuff
	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	public var camFollowObject:FlxObject;
	public var camFollow:FlxPoint;

	// music
	public var vocals:FlxSound;

	// notes
	public var renderedNotes:FlxTypedGroup<NoteRenderer>;
	public var pendingNotes:Array<Note> = [];

	// strums
	public var globalStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var strumLine:FlxPoint = FlxPoint.get();

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

	// stage stuff, will change because this is so fucking stupid
	public var stageData:Stage;
	public var cutsceneHandler:CutsceneHandler;
	public var dialogueHandler:DialogueBox;

	public var preStageRender:FlxTypedGroup<BGSprite>;
	public var postStageRender:FlxTypedGroup<BGSprite>;

	public var tankmenSoldiers:TankmenUnit;

	// information
	public var songName:String = '';
	public var songDiffText:String = ''; // ok fine, its a text too

	public var events:EventManager;

	// simple values
	public var songStarted:Bool = false;
	public var generatedMusic:Bool = false;
	public var countdownState:Int = 0; // 0 = countdown not started, 1 = countdown started, 2 = countdown finished
	public var gameEnded:Bool = false;
	public var paused:Bool = false;
	public var songSpeed:Float = 1.0; // no support for changing speed yet

	// various internal things
	private var ___trackedSoundObjects:Array<FlxSound> = [];
	private var ___trackedTimerObjects:FlxTimerManager = new FlxTimerManager();
	private var ___trackedTweenObjects:Array<FlxTween> = [];

	private static var _finishedCutscene:Bool = false;

	private var botplay:Bool = false;

	private static var _cameraPos:FlxPoint;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Conductor.songPosition = 0;

		current = this;

		gameCamera = new FlxCamera();
		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;
		pauseCamera = new FlxCamera();
		pauseCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(pauseCamera, false);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		gameInfo = new CurrentGame();

		FlxG.mouse.visible = false;

		persistentDraw = true;
		persistentUpdate = true;

		if (Song.currentSong == null)
			Song.loadSong('tutorial', 2);

		vocals = FlxG.sound.list.recycle(FlxSound);
		vocals.looped = false;
		vocals.attributes.set('isPlaying', false);
		if (vocals != null)
		{
			vocals.loadEmbedded(Paths.vocals(Song.currentSong.song));
			vocals.attributes.set('isPlaying', true);
			FlxG.sound.list.add(vocals);
		}
		var stageName:String = 'stage';

		if (Song.currentSong != null)
		{
			stageName = switch (Song.currentSong.song.toLowerCase().replace(' ', '-'))
			{
				case 'tutorial' | 'bopeebo' | 'fresh' | 'dad-battle' | 'dadbattle':
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
					'red-mall';
				case 'senpai' | 'roses':
					'school';
				case 'thorns':
					'dark-school';
				case 'ugh' | 'guns' | 'stress':
					'warzone';
				default:
					'stage-error';
			};

			trace(Song.currentSong.song.formatToReadable());
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
				case BEFORE_CHAR:
					preStageRender.add(spriteList);
				case AFTER_CHAR:
					postStageRender.add(spriteList);
			}
		}

		FlxG.camera.zoom = stageData.defaultZoom;
		FlxG.camera.attributes.set('zoomLerpValue', stageData.defaultZoom);

		add(preStageRender);

		var playerPos = stageData.charPosList.playerPositions;
		var specPos = stageData.charPosList.spectatorPositions;
		var oppPos = stageData.charPosList.opponentPositions;

		spectator = new Character(specPos[0].x, specPos[0].y, Song.currentSong.spectator, true);
		spectator.scrollFactor.set(0.95, 0.95);

		if (Song.currentSong.song.formatToReadable() == 'stress')
		{
			preStageRender.remove(stageData.spriteGroup['ground'], true);

			tankmenSoldiers = new TankmenUnit();
			add(tankmenSoldiers);
		}

		add(stageData.spriteGroup['ground']);
		add(spectator);

		player = new Character(playerPos[0].x, playerPos[0].y, Song.currentSong.player, true);
		player.__TYPE = PLAYER;
		player.scrollFactor.set(0.95, 0.95);
		add(player);

		opponent = new Character(oppPos[0].x, oppPos[0].y, Song.currentSong.opponent, false);
		opponent.scrollFactor.set(0.95, 0.95);
		opponent.overridePlayer = true;
		add(opponent);

		add(postStageRender);

		if (_cameraPos != null)
			_cameraPos.copyTo(camFollow);
		else
		{
			camFollow = FlxPoint.get();

			if (Song.currentSong.mustHitSections[0] != null)
			{
				var newPos:FlxPoint = FlxPoint.get();
				Tools.transformSimplePoint(newPos,
					(Song.currentSong.mustHitSections[0] ? stageData.camPosList.playerPositions[0] : stageData.camPosList.opponentPositions[0]));

				var midPoint:FlxPoint = (Song.currentSong.mustHitSections[0] ? player : opponent).getMidpoint();

				camFollow.set(midPoint.x + newPos.x, midPoint.y + newPos.y);
			}
		}
		_cameraPos = null;

		camFollowObject = new FlxObject(camFollow.x, camFollow.y, 1, 1);
		add(camFollowObject);

		FlxG.camera.follow(camFollowObject, null, 1);

		strumLine.y = 50;

		if (Settings.getPref('downscroll', false))
			strumLine.y = FlxG.height - 150;

		globalStrums = new FlxTypedGroup<StrumNote>();
		addToHUD(globalStrums);

		// no reason to add them, globalStrums is the renderer for strum notes
		playerStrums = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();

		addToHUD(playerStrums);
		addToHUD(opponentStrums);

		addPlayer(opponentStrums);
		addPlayer(playerStrums);

		generateSong();

		healthBarBG = new FlxSprite(0, FlxG.height * (Settings.getPref('downscroll', false) ? 0.1 : 0.9)).loadGraphic(Paths.image('game/ui/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		addToHUD(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), gameInfo,
			'health', 0, gameInfo.maxHealth);
		healthBar.scrollFactor.set();
		healthBar.numDivisions = healthBar.frameWidth;
		healthBar.createFilledBar(opponent.healthColor, player.healthColor);
		addToHUD(healthBar);

		iconP1 = new HealthIcon(0, 0, player.name);
		iconP1.origin.x = 0;
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.scrollFactor.set();
		iconP1.updateScale = true;
		iconP1.flipX = true;
		addToHUD(iconP1);

		iconP2 = new HealthIcon(0, 0, opponent.name);
		iconP2.origin.x = iconP2.width;
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.scrollFactor.set();
		iconP2.updateScale = true;
		addToHUD(iconP2);

		scoreText = new FlxText(0, 0, 0, "[Score] 0 // [Misses] 0 // [Rank] (0.00% - N/A)");
		scoreText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 1.25;
		scoreText.screenCenter(X);
		scoreText.y = healthBarBG.y + 30;
		addToHUD(scoreText);

		engineText = new FlxText(0, 0, 0, 'Crow Engine ${Main.engineVersion.display}');
		engineText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		engineText.borderSize = 1.25;
		engineText.x = FlxG.width - engineText.width - 40;
		engineText.y = healthBarBG.y + 30;
		addToHUD(engineText);

		Conductor.songPosition = -500;

		var countdownCallback:Void->Void = initCountdown.bind(null, null, 1000, function(e)
		{
			_finishedCutscene = true;

			for (charList in [playerList, opponentList, spectatorList])
			{
				if (charList != null)
				{
					for (char in charList)
					{
						if (char != null)
						{
							char.dance(true);

							if (char.attributes.exists('isForced') && char.attributes.get('isForced'))
								char.forceIdle = true;
						}
					}
				}
			}

			stageData.countdownTick();
		});

		if (playMode == STORY && !_finishedCutscene)
		{
			if (DialogueBox.songs.contains(Song.currentSong.song.formatToReadable()))
			{
				player.active = false;
				opponent.active = false;
				spectator.active = false;

				for (animated in stageData.spriteGroup.iterator())
				{
					if (animated.animation.frames > 0)
						animated.active = false;
				}

				dialogueHandler = new DialogueBox(Song.currentSong.song.formatToReadable());
				dialogueHandler.endCallback = function()
				{
					player.active = true;
					opponent.active = true;
					spectator.active = true;

					for (animated in stageData.spriteGroup.iterator())
					{
						if (animated.animation.frames > 0)
							animated.active = true;
					}

					new FlxTimer().start(0.05, function(tmr:FlxTimer)
					{
						hudCamera.alpha += 0.1;
					}, 10);

					countdownCallback();
				};
				dialogueHandler.camera = pauseCamera;
				add(dialogueHandler);

				Transitions.transOut = false;
			}
			else if (CutsceneHandler.checkCutscene(Song.currentSong.song.formatToReadable()))
			{
				cutsceneHandler = new CutsceneHandler(Song.currentSong.song.formatToReadable());
				cutsceneHandler.endCallback = countdownCallback;
			}
			else
				countdownCallback();
		}
		else
			countdownCallback();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);

		CacheManager.setAudio(Paths.music('gameOver'));
		CacheManager.setAudio(Paths.music('gameOverEnd'));
		CacheManager.setAudio(Paths.sound('game/death/fnf_loss_sfx'));

		super.create();
	}

	private function addToHUD(obj:FlxBasic, index:Int = null, ?group:FlxTypedGroup<FlxBasic> = null)
	{
		if (index == null)
			index = members.length + 1;

		if (obj != null)
		{
			obj.cameras = [hudCamera];
			(group == null ? this : group).insert(index, obj);
		}
	}

	private var _iconP1Offset:Float = 0.0;
	private var _iconP2Offset:Float = 0.0;

	private var _lastFrameTime:Int = 0;
	private var _songTime:Float = 0.0;

	override public function update(elapsed:Float)
	{
		if (pendingNotes.length != 0)
		{
			for (note in pendingNotes)
			{
				if (note.strumTime - Conductor.songPosition > 1500)
					break;

				if (note.mustPress)
				{
					if (note.isSustainNote)
						_isolatedNotes.sustains[note.direction].push(note);
					else
						_isolatedNotes.note[note.direction].push(note);
				}

				var currentNote:NoteRenderer = NoteRenderer.__pool.get();
				currentNote.exists = true;
				currentNote.refreshNote(note);
				if (currentNote.note.isEndNote && Settings.getPref('downscroll', false))
					currentNote.attributes.set('gapOffset', (currentNote.note._lastNote.noteRenderer.y - (currentNote.y + currentNote.height)));

				if (note.isSustainNote)
					renderedNotes.insert(0, currentNote);
				else
					renderedNotes.add(currentNote);
				pendingNotes.splice(pendingNotes.indexOf(note), 1);
			}
		}

		if (camFollow != null && camFollowObject != null)
		{
			var lerpVal:Float = elapsed * 2.4;
			camFollowObject.setPosition(Tools.lerpBound(camFollowObject.x, camFollow.x, lerpVal), Tools.lerpBound(camFollowObject.y, camFollow.y, lerpVal));
		}

		for (camera in FlxG.cameras.list)
		{
			if (camera.attributes.exists('zoomLerping') && camera.attributes.exists('zoomLerpValue'))
				camera.zoom = Tools.lerpBound(camera.zoom, camera.attributes['zoomLerpValue'], elapsed * 3.125);
		}

		if (FlxG.keys.justPressed.F7)
			super.openSubState(new states.debug.game.StageEditSubState());

		super.update(elapsed);

		stageData.update(elapsed);
		if (cutsceneHandler != null)
			cutsceneHandler.update(elapsed);

		if (iconP1 != null)
		{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - _iconP1Offset;
			iconP1.centerOverlay(healthBar, Y);

			if (iconP1.animation.curAnim.frames.length == 0 || iconP1.animation.curAnim.finished)
				iconP1.changeState(healthBar.percent < 20 ? 'lose' : 'neutral');
		}

		if (iconP2 != null)
		{
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - _iconP2Offset);
			iconP2.centerOverlay(healthBar, Y);

			if (iconP2.animation.curAnim.frames.length == 0 || iconP2.animation.curAnim.finished)
				iconP2.changeState(healthBar.percent > 80 ? 'lose' : 'neutral');
		}

		if (___trackedTimerObjects.active)
			___trackedTimerObjects.update(elapsed);

		if (countdownState != 0)
		{
			if (!gameEnded && controls.getKey('PAUSE', JUST_PRESSED))
			{
				if (songStarted)
				{
					FlxG.sound.music.resume();
					if (vocals.attributes.get('isPlaying'))
						vocals.resume();
				}

				paused = true;
				openSubState(new PauseSubState());
			}

			Conductor.songPosition += elapsed * 1000;

			if (countdownState == 1)
			{
				if (Conductor.songPosition >= 0)
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
					if (Conductor.songPosition - _songTime < 2000)
						_songTime = Conductor.songPosition;
					else
						_songTime = (_songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}

			if (gameInfo.health <= 0)
			{
				paused = true;
				persistentUpdate = persistentDraw = false;

				openSubState(new GameOverSubState());
			}

			inputQueries.update(elapsed);
			manageNotes();
		}

		if (events.eventList[0] != null)
		{
			for (event in events.eventList)
			{
				if (Conductor.songPosition >= event.strumTime)
					events.triggerEvent(event);
				else
					break;
			}
		}
	}

	override function beatHit():Void
	{
		super.beatHit();

		iconP1.beatHit();
		iconP2.beatHit();

		for (charList in [playerList, opponentList, spectatorList])
		{
			if (charList != null)
			{
				for (char in charList)
				{
					if (char != null)
					{
						char.dance();

						if (char.attributes.exists('isForced') && char.attributes.get('isForced'))
							char.forceIdle = true;
					}
				}
			}
		}
		if (camFollow != null)
		{
			var sect:Int = Math.floor(curBeat / 4);

			if (Song.currentSong.sectionList[sect] != null)
			{
				if (curBeat % Math.floor(Song.currentSong.sectionList[sect].length / 4) == 0)
				{
					if (Song.currentSong.mustHitSections[sect] != null)
					{
						var newPos:FlxPoint = FlxPoint.get();
						Tools.transformSimplePoint(newPos,
							(Song.currentSong.mustHitSections[sect] ? stageData.camPosList.playerPositions[0] : stageData.camPosList.opponentPositions[0]));

						var midPoint:FlxPoint = (Song.currentSong.mustHitSections[sect] ? player : opponent).getMidpoint();

						camFollow.set(midPoint.x + newPos.x, midPoint.y + newPos.y);
					}
				}
			}
		}

		stageData.beatHit(curBeat);
	}

	override function stepHit():Void
	{
		super.stepHit();

		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 30
			|| (Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 30))
		{
			resyncVocals();
		}
	}

	private function resyncVocals():Void
	{
		if (!gameEnded && songStarted)
		{
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;

			if (Conductor.songPosition < vocals.length) // fix the issue with the vocals randomly glitching
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	public function generateSong():Void
	{
		renderedNotes = new FlxTypedGroup<NoteRenderer>();
		addToHUD(renderedNotes);

		if (Song.currentSong == null)
			return;

		songName = Song.currentSong.song;
		songDiffText = SongHandler.PLACEHOLDER_DIFF[PlayState.songDiff];

		Conductor.changeBPM(Song.currentSong.bpm);

		attributes.set('startedCrochet', Conductor.stepCrochet);

		Conductor.mapBPMChanges(Song.currentSong);

		songSpeed = FlxMath.roundDecimal(Song.currentSong.speed, 2);

		events = new EventManager(Song.currentSong.song.formatToReadable(), true);

		var generatedTime = openfl.Lib.getTimer();

		// initialize note
		new Note();

		NoteRenderer.__pool = new FlxPool<NoteRenderer>(NoteRenderer);
		NoteRenderer.__pool.preAllocate(Std.int(Math.min(Song.currentSong.noteLength, 128)));

		for (sections in Song.currentSong.sectionList)
		{
			for (note in sections.notes)
			{
				var newNote:Note = new Note(note.strumTime, note.direction, note.mustPress, 0, 0, note.noteAnim);

				var oldNote:Note = newNote;
				if (pendingNotes.length > 0)
					oldNote = pendingNotes[Std.int(pendingNotes.length - 1)];

				newNote._lastNote = oldNote;
				newNote.missAnim = newNote.singAnim + 'miss';

				if (note.sustain > 0)
				{
					var sustainAmounts:Int = Math.floor(Math.max(2, note.sustain / Conductor.stepCrochet));

					for (i in 0...sustainAmounts)
					{
						var sustainNote:Note = new Note(note.strumTime + (Conductor.stepCrochet * i + 1), note.direction, note.mustPress, i + 1,
							sustainAmounts - 1, note.noteAnim);
						oldNote = sustainNote;
						if (pendingNotes.length > 0)
							oldNote = pendingNotes[Std.int(pendingNotes.length - 1)];

						sustainNote._lastNote = oldNote;
						sustainNote.sustainLength = sustainAmounts - 1;
						sustainNote.singAnim = newNote.singAnim;
						sustainNote.missAnim = newNote.missAnim;

						pendingNotes.push(sustainNote);
					}
				}

				pendingNotes.push(newNote);
			}
		}
		trace((openfl.Lib.getTimer() - generatedTime) + 'ms GENERATING NOTES');

		pendingNotes.sort(function(note1:Note, note2:Note)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime);
		});

		generatedMusic = true;
	}

	public function initCountdown(?list:Array<String> = null, ?sound:Array<String> = null, ?diff:Int = 1000, ?onProgress:Int->Void = null)
	{
		if (list == null)
			list = ['', 'ready', 'set', 'go'];
		if (sound == null)
			sound = ['3', '2', '1', 'Go'];

		list.unshift('');
		sound.unshift('');

		countdownState = 1;

		if (list.length == 0) // ok??? just assume the person wants to start instantly
		{
			if (onProgress != null)
				onProgress(0);
		}
		else
		{
			Conductor.songPosition = -(Conductor.crochet * list.length); // -5000 if the list has 4 things

			for (i in 0...list.length)
			{
				var countdownSpr:FlxSprite = new FlxSprite();
				countdownSpr.active = false;
				countdownSpr.visible = false;

				if (list[i] != '')
				{
					countdownSpr.loadGraphic(Paths.image('game/countdown/${Song.metaData.countdownSkin}/${list[i]}'));
					countdownSpr.visible = true;
					countdownSpr.alpha = 0.0;
					countdownSpr.scrollFactor.set();
					countdownSpr.screenCenter();
					countdownSpr.scale.set(SkinManager.countdownSkin.scale.x, SkinManager.countdownSkin.scale.y);
					countdownSpr.antialiasing = SkinManager.countdownSkin.forcedAntialias;
					addToHUD(countdownSpr);
				}

				var countdownSound:FlxSound = FlxG.sound.list.recycle(FlxSound);

				if (sound[i] != '')
				{
					countdownSound.loadEmbedded(Paths.sound('game/countdown/${Song.metaData.countdownSkin}/intro-${sound[i]}'));
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
							FlxDestroyUtil.destroy(countdownSpr);
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

			_lastFrameTime = FlxG.game.ticks;

			FlxG.sound.playMusic(Paths.inst(Song.currentSong.song));
			if (vocals != null && vocals.attributes.get('isPlaying'))
				vocals.play();

			FlxG.sound.music.onComplete = decideEnding;
		}
	}

	public function decideEnding():Void
	{
		if (#if !debug playMode == STORY && #end CutsceneHandler.checkCutscene(Song.currentSong.song.formatToReadable()))
		{
			cutsceneHandler = new CutsceneHandler(Song.currentSong.song.formatToReadable() + '-cutscene-end');
			cutsceneHandler.endCallback = endSong;
		}
		else
			endSong();
	}

	public function endSong()
	{
		gameEnded = true;
		persistentUpdate = false;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		if (vocals != null && vocals.attributes.get('isPlaying'))
			vocals.stop();

		ScoreContainer.setSong(Song.currentSong.song.formatToReadable(), songDiff,
			{score: gameInfo.score, misses: gameInfo.misses, accuracy: gameInfo.accuracy});

		_finishedCutscene = false;
		if (PlayState.playMode != CHARTING)
		{
			switch (PlayState.playMode)
			{
				case STORY:
					CurrentGame.weekScores.push({score: gameInfo.score, misses: gameInfo.misses, accuracy: gameInfo.accuracy});
					PlayState.storyPlaylist.shift();

					if (PlayState.storyPlaylist.length > 0)
					{
						Transitions.transIn = false;
						Transitions.transOut = false;

						if (CacheManager.cachedAssets[AUDIO].exists(Paths.instPath(Song.currentSong.song)))
							CacheManager.cachedAssets[AUDIO].get(Paths.instPath(Song.currentSong.song)).special = false;
						if (CacheManager.cachedAssets[AUDIO].exists(Paths.vocalsPath(Song.currentSong.song)))
							CacheManager.cachedAssets[AUDIO].get(Paths.vocalsPath(Song.currentSong.song)).special = false;

						Song.loadSong(PlayState.storyPlaylist[0].formatToReadable(), songDiff);
						MusicBeatState.switchState(new PlayState());
					}
					else
					{
						ScoreContainer.setWeek(Paths.currentLibrary, PlayState.songDiff, CurrentGame.weekScores);
						trace('set week');
						CurrentGame.weekScores = [];
						trace('killed week');
						MusicBeatState.switchState(new states.menus.StoryMenuState());
					}
				case FREEPLAY:
					MusicBeatState.switchState(new states.menus.FreeplayState());
				default:
					MusicBeatState.switchState(new states.menus.MainMenuState());
			}

			if (PlayState.playMode == FREEPLAY)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
			}
			else
			{
				FlxG.sound.music.volume = 0;
				FlxG.sound.music.stop();
			}
		}
		else
		{ // i dont have a fucking charting state yet moron
			PlayState.playMode = FREEPLAY;
			endSong();
		}
	}

	private function getPlaylist()
	{
		return PlayState.storyPlaylist;
	}

	override function openSubState(state:FlxSubState)
	{
		if (Std.isOfType(state, PauseSubState))
		{
			for (sound in ___trackedSoundObjects)
			{
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

		if (songStarted)
		{
			FlxG.sound.music.pause();
			if (vocals.attributes.get('isPlaying'))
				vocals.pause();
		}

		super.openSubState(state);
	}

	override function closeSubState()
	{
		for (sound in ___trackedSoundObjects)
		{
			sound.resume();
		}

		for (tween in ___trackedTweenObjects)
		{
			if (tween != null)
				tween.active = true;
		}

		persistentUpdate = true;

		___trackedTimerObjects.active = true;

		paused = false;

		if (songStarted && !gameEnded)
			resyncVocals();

		super.closeSubState();
	}

	private var _isolatedNotes:{sustains:Map<Int, Array<Note>>, note:Map<Int, Array<Note>>} = {
		note: [0 => [], 1 => [], 2 => [], 3 => []],
		sustains: [0 => [], 1 => [], 2 => [], 3 => []]
	};

	private var currentKeys:Array<Bool> = [];

	public var inputQueries:ControlQueries = new ControlQueries();

	public function keyPress(e:KeyboardEvent)
	{
		var direction:Int = getKeyDirection(e.keyCode);

		if (!botplay && !paused && generatedMusic && !gameEnded)
		{
			if (direction != -1 && FlxG.keys.checkStatus(e.keyCode, JUST_PRESSED))
			{
				if (currentKeys[direction] = true)
				{
					var lastTime:Float = Conductor.songPosition;
					Conductor.songPosition = FlxG.sound.music.time;

					var sortedNotesList:Array<Note> = [];
					var allowGhost:Bool = true;

					var pressNotes:Array<Note> = [];
					var notesStopped:Bool = false;

					for (note in _isolatedNotes.note[direction])
					{
						if (note.canBeHit && !note.tooLate && !note.wasGoodHit)
						{
							sortedNotesList.push(note);
							allowGhost = false;
						}
					}

					if (sortedNotesList.length > 0)
					{
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						for (epicNote in sortedNotesList)
						{
							for (doubleNote in pressNotes)
							{
								if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1)
									killNote(doubleNote);
								else
									notesStopped = true;
							}

							if (!notesStopped)
							{
								if (!epicNote.wasGoodHit)
								{
									hitNote(epicNote);
									pressNotes.push(epicNote);
								}
							}
						}
					}

					if (!Settings.getPref('ghost_tap', true) && allowGhost)
					{
						if (player._stunnedTimer <= 0.0)
							ghostMiss(direction);
					}

					Conductor.songPosition = lastTime;
				}

				var strum:StrumNote = playerStrums.members[direction];
				if (strum != null && strum.animation.curAnim.name != strum.confirmAnim && strum.animation.curAnim.name != strum.pressAnim)
				{
					strum.playAnim(strum.pressAnim);
					strum.animationTime = Conductor.stepCrochet * 1.5 / 1000;
				}
			}
		}
	}

	public function keyRelease(e:KeyboardEvent)
	{
		var direction:Int = getKeyDirection(e.keyCode);
		if (!paused && direction != -1)
		{
			var strum:StrumNote = playerStrums.members[direction];
			if (strum != null)
			{
				strum.playAnim(strum.staticAnim);
				strum.animationTime = 0.0;
			}
			currentKeys[direction] = false;
		}
	}

	private function getKeyDirection(key:Int)
	{
		var controlList:Array<Array<FlxKey>> = [];
		@:privateAccess
		{
			controlList = [
				controls.LIST_CONTROLS['NOTE_LEFT'].__keys,
				controls.LIST_CONTROLS['NOTE_DOWN'].__keys,
				controls.LIST_CONTROLS['NOTE_UP'].__keys,
				controls.LIST_CONTROLS['NOTE_RIGHT'].__keys,
			];
		}

		if (key != FlxKey.NONE)
		{
			for (i in 0...controlList.length)
			{
				for (j in 0...controlList[i].length)
				{
					if (controlList[i][j] == key)
						return i;
				}
			}
		}

		return -1;
	}

	public var strumRange:Float = FlxG.width / 2;

	private var _totalPlayers:Int = 0;

	public function addPlayer(strum:FlxTypedGroup<StrumNote>)
	{
		if (strum == null || strum.length != 0)
			return;

		strum.ID = _totalPlayers;

		for (i in 0...4)
		{
			var strumNote:StrumNote = new StrumNote(i);
			strumNote.ID = i;

			strumNote.x = 75 + (_totalPlayers == 0 ? 25 : 0) + (Note.transformedWidth * i) + (strumRange * _totalPlayers);
			strumNote.y = strumLine.y;

			strum.add(strumNote);
		}

		_totalPlayers++;
	}

	public function manageNotes():Void
	{
		if (generatedMusic)
		{
			var center = strumLine.y + (Note.transformedWidth / 2);

			renderedNotes.forEachAlive(function(renderer:NoteRenderer)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = renderer.note.mustPress ? playerStrums : opponentStrums;
				var strumNote:StrumNote = strumGroup.members[renderer.note.direction];

				var distance:Float = (-0.45 * (Conductor.songPosition - renderer.note.strumTime) * songSpeed);
				if (!Settings.getPref('downscroll', false))
					distance *= -1;

				if (renderer._lockedToStrumX)
				{
					renderer.x = strumNote.x;
					if (renderer.note.isSustainNote)
						renderer.centerOverlay(strumNote, X);
				}

				if (renderer.note.isSustainNote)
				{
					if (renderer._lockedScaleY)
					{
						if (!renderer.note.isEndNote)
						{
							renderer.scale.y = 1 * attributes['startedCrochet'] / 100 * 1.05;
							if (Note._noteFile.scaledHold.type == 'multi')
								renderer.scale.y *= Note._noteFile.scaledHold.y;
							renderer.scale.y *= songSpeed;
							renderer.updateHitbox();
						}
					}
				}

				if (renderer._lockedToStrumY)
				{
					renderer.y = strumNote.y - distance;
					if (renderer.note.isSustainNote && strumNote.downScroll)
					{
						if (!renderer.note.isEndNote)
							renderer.y -= (Note.transformedWidth / 2) * (songSpeed * 0.5);
						else
						{
							if (renderer.attributes.exists('gapOffset'))
								renderer.y += renderer.attributes['gapOffset'] + (6 * songSpeed);
						}
					}
					else if (renderer.note.isSustainNote)
					{
						renderer.y += (Note.transformedWidth / 2) * (songSpeed * 0.5);
					}
				}

				if (renderer.note.isSustainNote)
				{ // temporary fix because monster dies
					var _lastNote:Note = renderer.note._lastNote;
					if (_lastNote == null)
						_lastNote = renderer.note;

					if (strumNote.downScroll)
					{
						if (renderer.y - renderer.offset.y * renderer.scale.y + renderer.height >= center
							&& (!renderer.note.mustPress || (renderer.note.wasGoodHit || (_lastNote.wasGoodHit && !renderer.note.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, renderer.frameWidth, renderer.frameHeight);
							swagRect.height = (center - renderer.y) / renderer.scale.y;
							swagRect.y = renderer.frameHeight - swagRect.height;

							renderer.clipRect = swagRect;
						}
					}
					else
					{
						if (renderer.y + renderer.offset.y * renderer.scale.y <= center
							&& (!renderer.note.mustPress || (renderer.note.wasGoodHit || (_lastNote.wasGoodHit && !renderer.note.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, renderer.width / renderer.scale.x, renderer.height / renderer.scale.y);
							swagRect.y = (center - renderer.y) / renderer.scale.y;
							swagRect.height -= swagRect.y;

							renderer.clipRect = swagRect;
						}
					}
				}

				if (!renderer.note.mustPress && renderer.note.wasGoodHit)
				{
					if (renderer.note.strumTime <= Conductor.songPosition && !renderer.note._hitSustain)
						hitNote(renderer.note, true);
				}

				if (renderer.note.isSustainNote)
				{
					if ((Settings.getPref('downscroll', false) && renderer.y > FlxG.height * (1.0 + songSpeed))
						|| (!Settings.getPref('downscroll', false) && renderer.y < -renderer.height * (1.0 + songSpeed)))
						killNote(renderer.note);
				}

				if (renderer.note.mustPress && Conductor.songPosition >= renderer.note.strumTime && botplay)
					hitNote(renderer.note);
				else if (renderer.note.strumTime - Conductor.songPosition < -300)
				{
					if (renderer.note.mustPress)
						noteMiss(renderer.note);
				}

				if (!botplay && currentKeys.contains(true))
				{
					if (currentKeys[renderer.note.direction] && renderer.note.mustPress && renderer.note.isSustainNote && renderer.note.canBeHit)
					{
						player._animationTimer = 0.0;
						hitNote(renderer.note);
					}
				}
			});
		}
	}

	public function hitNote(note:Note, isOpponent:Bool = false)
	{
		if (!isOpponent)
		{
			if (!note.wasGoodHit)
			{
				var judgement = gameInfo.judgeNote(note.strumTime - Conductor.songPosition);
				var rate:Map<String, Float> = ['sick' => 1.0, 'good' => 0.75, 'bad' => 0.50, 'shit' => 0.25];
				var scoreRate:Map<String, Int> = ['sick' => 350, 'good' => 200, 'bad' => 75, 'shit' => 0];

				switch (judgement.judge)
				{
					case 'sick':
						{
							// insert notesplash
						}
				}

				if (player != null)
				{
					if (!player.animOffsets.exists(note.singAnim))
						player.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][Std.int(Math.abs(note.direction % 4))]);
					else
						player.playAnim(note.singAnim, true);
					player._animationTimer = 0.0;
				}

				var strum:StrumNote = playerStrums.members[note.direction];
				if (strum != null)
				{
					strum.playAnim(strum.confirmAnim, true);
					strum.animationTime = Conductor.stepCrochet * 1.5 / 1000;
				}

				note.wasGoodHit = true;

				if (vocals.attributes.get('isPlaying'))
					vocals.volume = 1.0;

				if (!note.isSustainNote)
				{
					gameInfo.playerHits += rate[judgement.judge];
					gameInfo.playerHitMods += 1.0;

					if (gameInfo.judgementList.exists(judgement.judge))
						gameInfo.judgementList[judgement.judge]++;

					gameInfo.score += scoreRate[judgement.judge];

					gameInfo.combo++;

					killNote(note);
					popCombo(judgement.judge);
				}

				gameInfo.health += FlxMath.remapToRange(0.45, 0, 100, 0, 2) * rate[judgement.judge];

				scoreText.text = '[Score] ${FlxStringUtil.formatMoney(gameInfo.score, false)} // [Misses] ${FlxStringUtil.formatMoney(gameInfo.misses, false)} // [Rank] (${Tools.formatAccuracy(FlxMath.roundDecimal(gameInfo.accuracy * 100, 2))}% - ${gameInfo.rank})';
				scoreText.screenCenter(X);

				reductionRate = Math.max(1, reductionRate - (0.75 * FlxMath.bound(gameInfo.combo / 10, 0.1, 80)));
			}
		}
		else
		{
			if (opponent != null)
			{
				if (!opponent.animOffsets.exists(note.singAnim))
					opponent.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][Std.int(Math.abs(note.direction % 4))]);
				else
					opponent.playAnim(note.singAnim, true);
				opponent._animationTimer = 0.0;
			}

			var strum:StrumNote = opponentStrums.members[note.direction];
			if (strum != null)
			{
				strum.playAnim(strum.confirmAnim, true);
				strum.animationTime = Conductor.stepCrochet * 0.001 * (note.isEndNote ? 2.5 : 1.25);
			}

			if (!note.isSustainNote)
				killNote(note);
			else
				note._hitSustain = true;

			if (vocals.attributes.get('isPlaying'))
				vocals.volume = 1.0;
		}
	}

	public var reductionRate:Float = 1.0;

	public function noteMiss(note:Note)
	{
		if (!note.wasGoodHit)
		{
			if (player != null)
			{
				player._animationTimer = -Conductor.stepCrochet * 0.001;
				player.playAnim(note.missAnim, true);
			}

			if (vocals.attributes.get('isPlaying'))
				vocals.volume = 0.0;

			gameInfo.misses++;
			gameInfo.playerHitMods++;

			gameInfo.health -= FlxMath.remapToRange(2, 0, 100, 0, 2) * reductionRate;

			var lastCombo = gameInfo.combo;

			gameInfo.combo = 0;

			if (lastCombo != 0 && !note.isSustainNote)
				popCombo('miss');

			gameInfo.score -= 25;

			killNote(note);

			reductionRate += FlxMath.roundDecimal(Math.min(reductionRate * 0.1, 0.5), 2) * (note.isSustainNote ? 0.25 : 1.0);
		}

		player._stunnedTimer = 0.5;
		player._animationTimer = -2.5;

		scoreText.text = '[Score] ${FlxStringUtil.formatMoney(gameInfo.score, false)} // [Misses] ${FlxStringUtil.formatMoney(gameInfo.misses, false)} // [Rank] (${Tools.formatAccuracy(FlxMath.roundDecimal(gameInfo.accuracy * 100, 2))}% - ${gameInfo.rank})';
		scoreText.screenCenter(X);
	}

	public function ghostMiss(direction:Int = -1)
	{
		if (direction != -1)
		{
			gameInfo.misses++;
			gameInfo.health -= FlxMath.remapToRange(1.75, 0, 100, 0, 2);

			if (player != null)
			{
				if (player.animOffsets.exists(player.missList[direction]))
					player.playAnim(player.missList[direction], true);
				else
					player.playAnim(['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'][direction]);
			}
		}

		player._stunnedTimer = 0.5;
		player._animationTimer = -2.5;

		scoreText.text = '[Score] ${FlxStringUtil.formatMoney(gameInfo.score, false)} // [Misses] ${FlxStringUtil.formatMoney(gameInfo.misses, false)} // [Rank] (${Tools.formatAccuracy(FlxMath.roundDecimal(gameInfo.accuracy * 100, 2))}% - ${gameInfo.rank})';
		scoreText.screenCenter(X);
	}

	public var showCombo:Bool = true;
	public var showNumbers:Bool = true;

	// apparently perf is shit whenever i make a new combo sprite, do this for now
	public var comboSpr:ComboSprite;
	public var lastNums:Map<String, ComboSprite> = [];
	public var numScores:Array<ComboSprite> = [];

	public function popCombo(rating:String = 'sick', ?optionalCombo:Null<Int>)
	{
		var xPos:Float = FlxG.width * 0.35;

		if (showCombo && rating != 'miss')
		{
			if (comboSpr == null || !comboSpr.alive)
				comboSpr = new ComboSprite();
			if (comboSpr.attributes.get('lastRating') != rating)
			{
				comboSpr.attributes.set('lastRating', rating);
				comboSpr.loadGraphic(Paths.image('game/combo/${Song.metaData.comboSkin}/ratings/' + rating));
			}
			comboSpr.scale.set(0.7 * SkinManager.comboSkin.scale.x, 0.7 * SkinManager.comboSkin.scale.y);
			comboSpr.updateHitbox();
			comboSpr.screenCenter();
			comboSpr.setPosition(xPos - 40, comboSpr.y - 60);

			comboSpr.antialiasing = SkinManager.comboSkin.forcedAntialias;

			comboSpr.acceleration.y = 550;
			comboSpr.velocity.y = -FlxG.random.int(140, 175);
			comboSpr.velocity.x = FlxG.random.int(0, 10) * FlxG.random.sign();

			comboSpr.delay = Conductor.crochet * 0.002;
			comboSpr.alpha = 1.0;
			comboSpr.active = true;

			addToHUD(comboSpr, members.indexOf(globalStrums));
		}

		if (showNumbers)
		{
			var comboString:String = Std.string(optionalCombo != null ? optionalCombo : gameInfo.combo).lpad("0", 3);
			var loop:Int = 0;

			FlxDestroyUtil.destroyArray(numScores);

			for (num in comboString.split(""))
			{
				if (num != '')
				{
					if (!lastNums.exists(num))
					{
						var createNum:ComboSprite = new ComboSprite();
						createNum.loadGraphic(Paths.image('game/combo/${Song.metaData.comboSkin}/numbers/num' + num));
						lastNums.set(num, createNum);
					}
					var numScore:ComboSprite = lastNums.get(num).cloneCombo();
					if (SkinManager.comboSkin.useActualScale)
						numScore.scale.set(SkinManager.comboSkin.scale.x, SkinManager.comboSkin.scale.y);
					else
						numScore.scale.set(0.5 * SkinManager.comboSkin.scale.x, 0.5 * SkinManager.comboSkin.scale.y);
					numScore.updateHitbox();
					numScore.screenCenter();
					numScore.setPosition(xPos + (43 * loop) - 90, numScore.y + 80);

					numScore.antialiasing = SkinManager.comboSkin.forcedAntialias;

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y = -FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					numScore.delay = Conductor.crochet * 0.001;
					numScore.alpha = 1.0;
					numScore.active = true;
					numScores.push(numScore);

					addToHUD(numScore, members.indexOf(globalStrums));

					loop++;
				}
			}
		}
	}

	private function killNote(note:Note)
	{
		if (note.mustPress)
		{
			if (note.isSustainNote)
			{
				if (_isolatedNotes.sustains[note.direction].contains(note))
					_isolatedNotes.sustains[note.direction].splice(_isolatedNotes.sustains[note.direction].indexOf(note), 1);
			}
			else
			{
				if (_isolatedNotes.note[note.direction].contains(note))
					_isolatedNotes.note[note.direction].splice(_isolatedNotes.note[note.direction].indexOf(note), 1);
			}
		}

		note.noteRenderer.exists = false;
		renderedNotes.remove(note.noteRenderer, true);
		NoteRenderer.__pool.put(note.noteRenderer);
	}

	override function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyRelease);

		Note._noteFile = null;
		StrumNote._strumFile = null;

		NoteRenderer.__pool = null;

		super.destroy();
	}
}

@:enum abstract PlayingMode(Int)
{
	var STORY:PlayingMode = 0x001;
	var FREEPLAY:PlayingMode = 0x010;
	var CHARTING:PlayingMode = 0x100;
}
