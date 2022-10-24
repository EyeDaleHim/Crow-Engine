package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import openfl.events.KeyboardEvent;
import music.Song;
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

	public var health(default, set):Float = 2.0;
	public var maxHealth(default, set):Float = 2.0;

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

	public var gameInfo:CurrentGame;

	// Camera Stuff
	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var otherCameras:Map<String, FlxCamera> = new Map();

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

	// public var strumNoteGroup:FlxTypedGroup<
	private static var _cameraPos:FlxPoint;

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		gameCamera = new FlxCamera();
		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(hudCamera);

		FlxCamera.defaultCameras = [gameCamera];

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		persistentDraw = true;
		persistentUpdate = true;

		/*if (Song.currentSong == null)
			Song.loadSong('tutorial', 2); */

		if (Song.currentSong != null)
		{
			var stageName:String = switch (Song.currentSong.song.formatToReadable())
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

		var stageName:String = 'stage';

		stageData = Stage.getStage(stageName);

		preStageRender = new FlxTypedGroup<BGSprite>();
		postStageRender = new FlxTypedGroup<BGSprite>();

		for (spriteList in stageData.spriteGroup)
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

		super.create();
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

		if (countdownState != 0)
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (countdownState == 1)
			{
				// if (Conductor.songPosition > 0)
				// startSong();
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
}
