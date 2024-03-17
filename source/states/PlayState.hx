package states;

import backend.game.Chart;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class PlayState extends MainState
{
	public static var instance:PlayState;

	// data
	public var isStory:Bool = false;

	public var chartFile:String = "";
	public var chartData:ChartData = DataManager.emptyChart;
	public var songMeta:SongMetadata;

	public var maxHealth:Float = 100.0;
	public var health:Float = 50.0;

	// cameras
	public var hudCamera:FlxCamera;

	// sprites
	// // hud
	public var infoText:FlxText;

	// // characters
	public var characterList:FlxTypedGroup<Character>;

	public var activeNotes:FlxTypedGroup<NoteSprite>;
	public var notes:Array<Note> = [];
	public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

	public var controlledStrums:Array<FlxTypedGroup<StrumNote>> = [];

	public function new(chartFile:String = "", isStory:Bool = false)
	{
		super();

		this.chartFile = chartFile;
		this.isStory = isStory;

		MainState.conductor.position = 0.0;
		MainState.conductor.active = false;

		if (FileSystem.exists(Assets.assetPath('data/songs/$chartFile.json')))
			DataManager.loadedCharts.set(chartFile, Json.parse(Assets.assetPath('data/songs/$chartFile.json')));
		else
			chartData = DataManager.emptyChart;

		instance = this;
	}

	override function create()
	{
		hudCamera = new FlxCamera();
		FlxG.cameras.add(hudCamera, false);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.mouse.visible = false;

		generateSong();

		activeNotes = new FlxTypedGroup<NoteSprite>();

		for (i in 0...(chartData.playerNum ?? 2))
		{
			generateStrum(FlxG.width / 2);
		}

		var controlledPlayers:Array<Int> = chartData.controlledStrums ?? [1];
		for (i in 0...controlledPlayers.length)
		{
			if (strumList[controlledPlayers[i]] != null)
				controlledStrums.push(strumList[controlledPlayers[i]]);
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyRelease);

		super.create();
	}

	public function generateStrum(gap:Float):Void
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

	override public function update(elapsed:Float)
	{
		if (notes.length > 0)
		{
			var spawnTime:Float = 3000 / songMeta.speed;

			var i:Int = notes.length;

			while (i >= 0)
			{
				if (notes[i].strumTime - (MainState.conductor.position - MainState.conductor.offset) <= spawnTime)
				{
					var noteSpr:NoteSprite = activeNotes.recycle(NoteSprite);
					noteSpr.noteData = notes[i];

					activeNotes.add(noteSpr);
				}
				else
				{
					notes.splice(i, notes.length);
					break;
				}
				i--;
			}
		}

		super.update(elapsed);
	}
}
