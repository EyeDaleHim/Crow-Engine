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

	public var safeFrames:Float = 10;

	// player stats
	public var maxHealth:Float = 100.0;
	public var health:Float = 50.0;

	public var score:Int = 0;

	public var misses:Int = 0;

	public var ratingHits:Float = 0.0;
	public var totalHits:Int = 0;

	public var combo:Int = 0;

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

	public var comboGroup:FlxTypedContainer<FlxSprite>;
	public var ratingGroup:FlxTypedContainer<FlxSprite>;

	// // characters
	public var characterList:FlxTypedGroup<Character>;

	// // notes & strums
	public var activeNotes:FlxTypedGroup<NoteSprite>;
	public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

	public var notes:Array<Note> = [];
	public var inputNotes:Array<Note> = [];

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

		add(activeNotes);

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

		infoText = new FlxText();
		infoText.setFormat(Assets.font("vcr").fontName, 18);
		infoText.camera = hudCamera;
		infoText.centerOverlay(healthBarBG, X);
		infoText.y = healthBarBG.objBottom() + 10;

		updateScoreText();

		add(infoText);

		comboGroup = new FlxTypedContainer<FlxSprite>();
		comboGroup.camera = hudCamera;
		add(comboGroup);

		ratingGroup = new FlxTypedContainer<FlxSprite>();
		ratingGroup.camera = hudCamera;
		add(ratingGroup);
	}

	public function createStrum(gap:Float):Void
	{
		var strumGroup:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
		strumGroup.ID = strumList.length;
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
			// notes.push(new Note(conductor.stepCrochet * i * 2.5, FlxG.random.int(0, 3), 0));
			notes.push(new Note(conductor.stepCrochet * i * 2.5, FlxG.random.int(0, 3), 1));
		}

		var copy:Array<Note> = [];
		for (note in notes)
		{
			copy.push(new Note(note.strumTime, note.direction, 0));
		}
		notes = notes.concat(copy);

		notes.sort((a:Note, b:Note) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
		});
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

			for (note in inputNotes)
			{
				if (note.canBeHit(conductor.position, (safeFrames / 60.0) * 1000.0) && note.direction == dir)
				{
					confirm = true;

					hitNote(note);
				}
			}

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
					var noteSpr:NoteSprite = activeNotes.recycle(NoteSprite, function()
					{
						var noteInstance:NoteSprite = new NoteSprite(notes[i]);
						noteInstance.camera = hudCamera;

						return noteInstance;
					});
					noteSpr.noteData = notes[i];

					activeNotes.add(noteSpr);
					_removeNotes.push(notes[i]);

					if (determineStrums(notes[i]))
						inputNotes.push(notes[i]);
				}
				else
					break;
			}

			for (note in _removeNotes.splice(0, _removeNotes.length))
				notes.remove(note);
		}

		var position:Float = (conductor.position - conductor.offset);

		activeNotes.forEachAlive(function(note:NoteSprite)
		{
			var distance:Float = (0.45 * (position - note.noteData.strumTime) * songMeta.speed);

			var strumGroup:FlxTypedGroup<StrumNote> = strumList[note.noteData.side];
			var strumNote:StrumNote = strumGroup.members[note.noteData.direction];

			note.centerOverlay(strumNote, X);
			note.y = strumNote.y - distance;

			if (!determineStrums(note.noteData) && note.noteData.strumTime - position < 0)
			{
				hitNote(note.noteData);
			}
			else if (note.noteData.strumTime - position < -300 && determineStrums(note.noteData))
			{
				missNote(note.noteData);
			}
		});

		for (note in _removeNotes.splice(0, _removeNotes.length))
		{
			destroyNote(note);
		}

		comboGroup.forEachAlive(function(spr:FlxSprite)
		{
			spr.customData.set("actualAlpha", spr.alpha - (elapsed * 2));
			spr.alpha = spr.customData.get("actualAlpha");

			if (spr.alpha <= 0.0)
				spr.kill();
		});

		ratingGroup.forEachAlive(function(spr:FlxSprite)
		{
			spr.customData.set("actualAlpha", spr.alpha - (elapsed * 2));
			spr.alpha = spr.customData.get("actualAlpha");

			if (spr.alpha <= 0.0)
				spr.kill();
		});

		timerManager.update(elapsed);
		tweenManager.update(elapsed);

		super.update(elapsed);
	}

	public function updateScoreText():Void
	{
		var separator:String = "//";

		var scoreString:String = 'Score: $score';
		var missString:String = 'Misses: $misses';

		var roundedAccuracy:Float = ratingHits / totalHits;
		if (Math.isNaN(roundedAccuracy))
			roundedAccuracy = 0.0;

		var accuracyString:String = 'Accuracy: ${FlxMath.roundDecimal(roundedAccuracy * 100.0, 2)}%';

		infoText.text = '$scoreString $separator $missString $separator $accuracyString';
		infoText.centerOverlay(healthBarBG, X);
	}

	public function hitNote(note:Note, diff:Float = 0.0)
	{
		if (determineStrums(note))
		{
			score += 500;

			ratingHits += 1.0;
			totalHits++;

			combo++;

			popUpCombo();
			updateScoreText();
		}
		else if (strumList[note.side] != null)
		{
			var strum:StrumNote = strumList[note.side].members[note.direction];
			strum.playAnim(strum.confirmAnim, true);

			if (strum.animation.finishCallback == null)
			{
				strum.animation.finishCallback = function(name:String)
				{
					if (name == strum.confirmAnim)
					{
						strum.animation.finishCallback = null;
						strum.playAnim(strum.staticAnim);
					}
				};
			}
		}

		destroyNote(note);
	}

	public function missNote(note:Note)
	{
		misses++;
		totalHits++;

		updateScoreText();

		FlxG.sound.play(Assets.sfx('game/miss/missnote${FlxG.random.int(1, 3)}'), 0.4);

		destroyNote(note);
	}

	public function destroyNote(note:Note)
	{
		if (inputNotes.indexOf(note) != -1)
			inputNotes.splice(inputNotes.indexOf(note), 1);
		activeNotes.remove(note.parent, true);

		if (note?.parent != null)
		{
			note.parent.kill();
		}
	}

	public function popUpCombo():Void
	{
		var ratingSpr = ratingGroup.recycle(FlxSprite);
		ratingSpr.camera = hudCamera;
		ratingSpr.loadGraphic(Assets.image('game/combo/ratings/sick'));

		ratingSpr.scale.set(0.7, 0.7);
		ratingSpr.updateHitbox();

		ratingSpr.screenCenter();
		ratingSpr.x -= ratingSpr.width / 2;
		ratingSpr.y -= ratingSpr.height / 2;

		ratingSpr.acceleration.y = 550;
		ratingSpr.velocity.y = -FlxG.random.int(140, 175);
		ratingSpr.velocity.x = FlxG.random.int(0, 10) * FlxG.random.sign();

		ratingSpr.customData.set("actualAlpha", 1.5);
		ratingSpr.alpha = 1.0;

		ratingGroup.add(ratingSpr);

		var numberStr:String = Std.string(combo).lpad("0", 3);
		var lastComboSpr:FlxSprite = null;

		for (i in 0...numberStr.length)
		{
			var str:String = numberStr.charAt(i);

			var comboSpr:FlxSprite = comboGroup.recycle(FlxSprite);
			comboSpr.camera = hudCamera;
			comboSpr.loadGraphic(Assets.image('game/combo/numbers/num$str'));

			if (lastComboSpr == null)
			{
				comboSpr.setPosition(ratingSpr.objRight() - (ratingSpr.width / 2), ratingSpr.objBottom());
			}
			else
			{
				comboSpr.setPosition(lastComboSpr.objRight() + 2, lastComboSpr.y);
			}

			comboSpr.scale.set(0.5, 0.5);
			comboSpr.updateHitbox();

			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y = -FlxG.random.int(140, 160);
			comboSpr.velocity.x = FlxG.random.float(-5, 5);

			comboSpr.customData.set("actualAlpha", 1.5);
			comboSpr.alpha = 1.0;

			comboGroup.add(comboSpr);

			lastComboSpr = comboSpr;
		}
	}

	private function determineStrums(note:Note):Bool
	{
		if (note != null)
		{
			for (strum in controlledStrums)
			{
				if (strum.ID == note.side)
					return true;
			}
		}
		return false;
	}
}
