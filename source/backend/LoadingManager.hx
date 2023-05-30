package backend;

import backend.Transitions;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxPool;
import flixel.util.FlxSort;
import sys.thread.FixedThreadPool;
import sys.FileSystem;
import states.PlayState;
import music.Song;
import objects.Stage;
import objects.character.Character;
import objects.notes.Note;
import objects.notes.Note.NoteSprite;
import backend.arrays.CircularBuffer;
import backend.graphic.CacheManager;

// only loads to playstate
@:access(objects.notes.Note)
class LoadingManager extends MusicBeatState
{
	static inline var LOADING_SPRITE_TIME:Float = 2.0;

	public static var lastTime:Int = 0;

	public static var activated:Bool = false;
	public static var __THREADPOOLS:FixedThreadPool = new FixedThreadPool(8);
	private static var _GAME_VARS:Map<ItemRequest, Array<Dynamic>> = [];


	private var finishedItems:Array<ItemRequest> = [];

	private var loadingSprite:FlxSprite;

	public static function getItem(item:ItemRequest)
	{
		if (_GAME_VARS.exists(item))
		{
			var returnedItem = _GAME_VARS.get(item);
			_GAME_VARS.remove(item);
			return returnedItem;
		}

		return null;
	}

	public static function startGame():Void
	{
		MusicBeatState.switchState(new LoadingManager());
	}

	public override function new()
	{
		Transitions.transOut = false;

		super();
	}

	override function create():Void
	{
		activated = true;

		lastTime = openfl.Lib.getTimer();

		__THREADPOOLS.run(loadStage);
		__THREADPOOLS.run(loadSong);
		__THREADPOOLS.run(loadCharacters);
		__THREADPOOLS.run(loadImages);
		__THREADPOOLS.run(loadSounds);

		loadingSprite = new FlxSprite().loadGraphic(Paths.image('loading'));
		loadingSprite.antialiasing = true;
		loadingSprite.angle = Math.random() * 360;
		loadingSprite.angularVelocity = 360;
		loadingSprite.setPosition(FlxG.width - 128, FlxG.height - 128);
		loadingSprite.alpha = 0.0;
		loadingSprite.active = false;
		add(loadingSprite);

		super.create();
	}

	private var TIME_INDEX:Float = 0.0;

	override function update(elapsed:Float)
	{
		TIME_INDEX += elapsed;

		if (TIME_INDEX > LOADING_SPRITE_TIME)
			loadingSprite.alpha = TIME_INDEX - LOADING_SPRITE_TIME;

		if (activated && finishedItems.length >= 3)
		{
			activated = false;
			persistentUpdate = false;
			MusicBeatState.switchState(new PlayState());
        }

		super.update(elapsed);
	}

	private function loadImages():Void
	{
		for (spr in FileSystem.readDirectory(Paths.imagePath('game/countdown/${Song.metaData.countdownSkin}').replace('.png', '')))
		{
			if (!spr.endsWith('json'))
				Paths.image('game/countdown/${Song.metaData.countdownSkin}/$spr');
		}

		Paths.image('game/ui/healthBar');
	}

	private function loadSounds():Void
	{
		CacheManager.setAudio(Paths.music('gameOver'));
		CacheManager.setAudio(Paths.music('gameOverEnd'));
		CacheManager.setAudio(Paths.sound('game/death/fnf_loss_sfx'));
	}

	private function loadCharacters():Void
	{
		var player = new Character(Song.currentSong.player, true);
		player.__TYPE = PLAYER;

		var opponent = new Character(Song.currentSong.opponent, false);
		opponent.overridePlayer = true;
		for (trail in opponent.trails)
			trail.visible = false;

		var spectator = new Character(Song.currentSong.spectator, true);

		_GAME_VARS.set(CHARS, [player, opponent, spectator]);

		finishedItems.push(CHARS);
	}

	private function loadStrums():Void
	{

	}

	private function loadSong():Void
	{
		Paths.inst(Song.currentSong.song);
		Paths.vocals(Song.currentSong.song);

        var noteList:Array<Note> = [];

		// initialize note
		new Note();

		NoteSprite.__pool = new FlxPool<NoteSprite>(NoteSprite);
		NoteSprite.__pool.preAllocate(32);

		for (sections in Song.currentSong.sectionList)
		{
			for (note in sections.notes)
			{
				var sustainAmounts:Float = Math.max(0, note.sustain / Conductor.stepCrochet);

				if (sustainAmounts > 0)
					sustainAmounts += 1;

				var newNote:Note = null;
				
				if (note.sustain > 0)
					newNote = new Note(note.strumTime, note.direction, note.mustPress, sustainAmounts, note.noteAnim);
				else
					newNote = new Note(note.strumTime, note.direction, note.mustPress, 0, note.noteAnim);

				var oldNote:Note = newNote;
				if (noteList.length > 0)
					oldNote = noteList[Std.int(noteList.length - 1)];

				newNote._lastNote = oldNote;
				newNote.missAnim = newNote.singAnim + 'miss';

				noteList.push(newNote);
			}
		}

		noteList.sort(function(note1:Note, note2:Note)
		{
			return FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime);
		});

		var notesBuffer:CircularBuffer<Note> = CircularBuffer.fromArray(noteList);

		finishedItems.push(SONGS);
        _GAME_VARS.set(SONGS, [notesBuffer]);
	}

	private function loadStage():Void
	{
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

		_GAME_VARS.set(STAGE, [
			Stage.getStage(stageName),
			new FlxTypedGroup<BGSprite>(),
			new FlxTypedGroup<BGSprite>()
		]);

		finishedItems.push(STAGE);
	}
}

enum abstract ItemRequest(Int)
{
	var STAGE:ItemRequest = 0;
	var SONGS:ItemRequest = 1;
	var CHARS:ItemRequest = 2;
}
