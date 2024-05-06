package states;

import backend.game.Chart;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class PlayState extends MainState
{
	public static var instance:PlayState;

	// quick getters
	public var conductor(get, never):Conductor;

	function get_conductor():Conductor
	{
		return MainState.conductor;
	}

	// data
	public var isStory:Bool = false;

	public var chartFile:String = "";
	public var chartData:ChartData = DataManager.emptyChart;
	public var songMeta:SongMetadata;

	public var maxHealth:Float = 100.0;
	public var health:Float = 50.0;

	// // managers
	public var timerManager:FlxTimerManager;
	public var tweenManager:FlxTweenManager;

	// cameras
	public var hudCamera:FlxCamera;

	// sprites
	// // hud
	public var infoText:FlxText;

	public var healthBar:FlxBar;
	public var healthBarBG:FlxSprite;

	// // characters
	public var characterList:FlxTypedGroup<Character>;

	// // notes & strums
	public var activeNotes:FlxTypedGroup<NoteSprite>;
	public var notes:Array<Note> = [];
	public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

	public var controlledStrums:Array<FlxTypedGroup<StrumNote>> = [];

	public function new(folder:String = "", chartFile:String = "", isStory:Bool = false)
	{
		super();

		this.chartFile = chartFile;
		this.isStory = isStory;

		conductor.position = 0.0;
		conductor.active = false;

		if (FileSystem.exists(Assets.assetPath('songs/$folder/$chartFile.json')))
		{
			DataManager.loadedCharts.set(chartFile, Json.parse(Assets.readText(Assets.assetPath('songs/$folder/$chartFile.json'))));
			chartData = DataManager.loadedCharts.get(chartFile);

			if (chartData.overrideMeta != null)
				songMeta = chartData.overrideMeta;
		}

		if (FileSystem.exists(Assets.assetPath('songs/$folder/meta.json')) && songMeta == null)
			songMeta = Json.parse(Assets.readText(Assets.assetPath('songs/$folder/meta.json')));

		if (songMeta == null)
			songMeta = {
				player: "bf",
				spectator: "gf",
				opponent: "dad",

				bpm: 100,
				speed: 1.0,
				stage: "stage"
			};

		MainState.musicHandler.loadInst('songs/$folder/Inst', 0.8, false);
		MainState.musicHandler.loadVocal('songs/$folder/Voices', 0.8, false);

		instance = this;
	}

	override function create()
	{
		initVars();

		hudCamera = new FlxCamera();
		FlxG.cameras.add(hudCamera, false);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.mouse.visible = false;

		generateSong();

		activeNotes = new FlxTypedGroup<NoteSprite>();

		for (i in 0...(chartData.playerNum ?? 2))
		{
			createStrum(FlxG.width / 2);
		}

		createHUD();

		var controlledPlayers:Array<Int> = chartData.controlledStrums ?? [1];
		for (i in 0...controlledPlayers.length)
		{
			if (strumList[controlledPlayers[i]] != null)
				controlledStrums.push(strumList[controlledPlayers[i]]);
		}

		startCountdown(startSong);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);

		super.create();
	}

	private function initVars():Void
	{
		timerManager = new FlxTimerManager();
		tweenManager = new FlxTweenManager();
	}

	public function createHUD():Void
	{
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Assets.image("game/ui/healthBar"));
		healthBarBG.camera = hudCamera;
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, (healthBarBG.width - 8).floor(), (healthBarBG.height - 8).floor(), this,
			'health', 0, maxHealth);
		healthBar.camera = hudCamera;
		healthBar.createFilledBar(FlxColor.RED, FlxColor.LIME);
		add(healthBar);

		infoText = new FlxText("[Score] 0 / [Misses] 0 / [Accuracy] 0%");
		infoText.setFormat(Assets.font("vcr").fontName, 18);
		infoText.camera = hudCamera;
		infoText.centerOverlay(healthBarBG, X);
		infoText.y = healthBarBG.objBottom() + 10;
		add(infoText);
	}

	public function createStrum(gap:Float):Void
	{
		var strumGroup:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
		strumGroup.camera = hudCamera;

		var startX:Float = 75 + (gap * strumList.length);
		var startY:Float = 50;

		for (i in 0...4)
		{
			var strumNote:StrumNote = new StrumNote(i);
			strumNote.ID = i;

			strumNote.x = startX + (strumList.length == 0 ? 25 : 0) + (Note.noteWidth * i);
			strumNote.y = startY;

			strumGroup.add(strumNote);
		}

		add(strumGroup);

		strumList.push(strumGroup);
	}

	public function generateSong():Void
	{
		notes = Chart.read(chartData);

		for (i in 0...256)
		{
			notes.push(new Note(conductor.stepCrochet * i, FlxG.random.int(0, 3), FlxG.random.int(0, 1)));
		}

		notes.sort((a:Note, b:Note) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
		});

		trace(notes);
	}

	public function startCountdown(finishCallback:() -> Void = null):Void
	{
		if (finishCallback != null)
			finishCallback();
	}

	public function startSong():Void
	{
		MainState.musicHandler.playInst(0.8, false);
		MainState.musicHandler.playAllVocal();

		conductor.sound = MainState.musicHandler.inst;
	}

	public function keyPress(event:KeyboardEvent)
	{
		var dir:Int = -1;

		// substitute code
		if (event.keyCode == FlxKey.A)
			dir = 0;
		else if (event.keyCode == FlxKey.S)
			dir = 1;
		else if (event.keyCode == FlxKey.W)
			dir = 2;
		else if (event.keyCode == FlxKey.D)
			dir = 3;

		if (FlxG.state.active && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED))
		{
			var confirm:Bool = false;

			if (confirm)
			{
				for (strum in controlledStrums)
				{
					strum.members[dir].playAnim(strum.members[dir].confirmAnim);
				}
			}
			else
			{
				for (strum in controlledStrums)
				{
					strum.members[dir].playAnim(strum.members[dir].pressAnim);
				}
			}
		}
	}

	public function keyRelease(event:KeyboardEvent)
	{
		var dir:Int = -1;

		// substitute code
		if (event.keyCode == FlxKey.A)
			dir = 0;
		else if (event.keyCode == FlxKey.S)
			dir = 1;
		else if (event.keyCode == FlxKey.W)
			dir = 2;
		else if (event.keyCode == FlxKey.D)
			dir = 3;

		if (FlxG.state.active && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED))
		{
			for (strum in controlledStrums)
			{
				strum.members[dir].playAnim(strum.members[dir].staticAnim);
			}
		}
	}

	var _removeNotes:Array<Note> = [];

	override public function update(elapsed:Float)
	{
		conductor.update(elapsed);

		if (notes.length > 0)
		{
			var spawnTime:Float = 3000 / songMeta.speed;

			for (i in 0...notes.length)
			{
				if (notes[i] == null)
					continue;

				if (notes[i].strumTime - (conductor.position - conductor.offset) <= spawnTime)
				{
					var noteSpr:NoteSprite = activeNotes.recycle(NoteSprite);
					noteSpr.noteData = notes[i];

					activeNotes.add(noteSpr);
					_removeNotes.push(notes[i]);
				}
				else
					break;
			}

			for (note in _removeNotes.splice(0, _removeNotes.length))
				notes.remove(note);
		}

		timerManager.update(elapsed);
		tweenManager.update(elapsed);

		super.update(elapsed);
	}

	public function updateNotes():Void
	{
	}
}
