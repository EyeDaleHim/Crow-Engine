package states;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;

class PlayState extends MainState
{
	public static var instance:PlayState;

	public var pauseMenu:PauseSubState;

	// data
	public var isStory:Bool = false;

	public var chartFile:String = "";
	public var chartData:ChartData = WeekManager.emptyChart;
	public var songMeta:SongMetadata;

	public var safeFrames:Float = 10;

	public var gameStarted:Bool = false;
	public var gameRestarted:Bool = false;

	public var paused:Bool = false;

	public var songPosition(get, never):Float;

	function get_songPosition():Float
	{
		return (conductor.position - conductor.offset);
	}

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

	public var soundList:Array<FlxSound> = [];

	// cameras
	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	// sprites
	// // hud
	public var infoText:FlxText;

	public var healthBar:FlxBar;
	public var healthBarBG:FlxSprite;

	public var comboGroup:FlxTypedContainer<FlxSprite>;
	public var ratingGroup:FlxTypedContainer<FlxSprite>;

	// // characters
	public var characterList:FlxTypedGroup<Character>;

	public var playerList:Array<Character> = [];
	public var spectatorList:Array<Character> = [];
	public var opponentList:Array<Character> = [];

	// // notes & strums
	public var activeNotes:FlxTypedGroup<NoteSprite>;
	public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

	public var notes:Array<Note> = [];
	public var inputNotes:Array<Note> = [];

	public var controlledStrums:Array<FlxTypedGroup<StrumNote>> = [];

	public function new(folder:String = "", chartFile:String = "", isStory:Bool = false)
	{
		super();

		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		pauseCamera = new FlxCamera();
		pauseCamera.bgColor = 0x000000;
		pauseCamera.bgColor.alphaFloat = 0.0;
		pauseCamera.visible = false;

		destroySubStates = false;

		pauseMenu = new PauseSubState(pauseCamera);
		pauseMenu.closeCallback = function()
		{
			paused = false;

			conductor.active = true;

			for (action in pauseMenu.actions)
			{
				action.active = false;
			}

			pauseCamera.bgColor.alphaFloat = 0.0;
			pauseCamera.visible = false;
			@:privateAccess
			if (!pauseMenu._songRestarted)
			{
				musicHandler.resumeChannel(0, 0.8, false);
				musicHandler.resumeChannel(1, false);
			}
			else
				pauseMenu._songRestarted = false;
		};

		Controls.registerFunction(Control.PAUSE, JUST_PRESSED, function()
		{
			trace("we called pause");
			if (!paused && pauseMenu != null)
			{
				musicHandler.pauseChannels();

				openSubState(pauseMenu);
				paused = true;
				conductor.active = false;
			}
		});

		for (action in pauseMenu.actions)
		{
			action.active = false;
		}

		FlxG.autoPause = true;

		musicHandler.clearChannels();

		this.chartFile = chartFile;
		this.isStory = isStory;

		conductor.position = 0.0;
		conductor.active = false;

		var file:String = Assets.assetPath('data/songs/${folder.toLowerCase()}/$chartFile.json');

		if (FileSystem.exists(file))
		{
			var data:ChartData = Json.parse(Assets.readText(file));

			WeekManager.loadedCharts.set(chartFile, data);
			chartData = data;

			if (chartData.overrideMeta != null)
				songMeta = chartData.overrideMeta;
		}
		else
		{
			Logs.error(NoChart(file, chartFile));
		}

		if (FileSystem.exists(Assets.assetPath('songs/$folder/meta.json')) && songMeta == null)
			songMeta = Json.parse(Assets.readText(Assets.assetPath('songs/$folder/meta.json')));

		if (songMeta == null)
			songMeta = {
				characters: {
					players: ["bf"],
					spectators: ["gf"],
					opponents: ["dad"]
				},

				channels: ["Inst", "Voices"],

				bpm: 100,
				speed: 1.0,
				stage: "stage"
			};

		conductor.bpm = songMeta.bpm;

		for (channel in songMeta.channels)
		{
			musicHandler.loadChannel('songs/$folder/$channel', 0.8, false);
		}

		var longChannel:FlxSound = null;

		for (channel in musicHandler.channels)
		{
			if (channel.exists && channel.length > longChannel?.length)
				longChannel = channel;
		}

		if (longChannel != null)
			longChannel.onComplete = endSong;

		instance = this;
	}

	override function create()
	{
		initVars();

		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(pauseCamera, false);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.mouse.visible = false;

		characterList = new FlxTypedGroup<Character>();
		add(characterList);

		for (player in songMeta.characters.players)
		{
			var char:Character = new Character(400, 260, player);
			char.scrollFactor.set(0.95, 0.95);
			characterList.add(char);
			playerList.push(char);

			conductor.onBeat.add(function(beat:Int)
			{
				char.beatHit();
			});
		}

		generateSong();

		activeNotes = new FlxTypedGroup<NoteSprite>();

		for (i in 0...(chartData.strumLength ?? 2))
		{
			createStrum(FlxG.width / 2);
		}

		add(activeNotes);

		createHUD();

		var controlledPlayers:Array<Int> = chartData.playerControllers ?? [1];
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

		add(timerManager);
		add(tweenManager);
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
		healthBar.numDivisions = 250;
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

		musicHandler.pauseChannels();
	}

	public function startCountdown(finishCallback:() -> Void = null):Void
	{
		var list:Array<String> = ["three", "two", "one", "go"];
		var len:Int = list.length;

		var graphs:Array<FlxGraphic> = [];
		var sounds:Array<Sound> = [];

		var countdownSpr:FlxSprite = new FlxSprite();
		countdownSpr.alpha = 0.0;
		countdownSpr.camera = hudCamera;
		add(countdownSpr);

		for (item in list)
		{
			if (Assets.exists(Assets.imagePath('game/countdown/$item')))
				graphs.push(Assets.image('game/countdown/$item'));
			else
				graphs.push(null);

			if (Assets.exists(Assets.soundPath('game/countdown/$item', SFX)))
				sounds.push(Assets.sound('game/countdown/$item', SFX));
			else
				sounds.push(null);
		}

		tweenManager.num(-conductor.crochet * (len + 1), 0.0, conductor.crochet * 0.001 * (len + 1), function(v:Float)
		{
			conductor.position = v;
		});

		var tmr:FlxTimer = FlxTimer.loop(conductor.crochet * 0.001, function(loop)
		{
			if (loop == len + 1 && finishCallback != null)
			{
				FlxDestroyUtil.destroy(countdownSpr);

				finishCallback();
			}
			else
			{
				if (graphs[loop - 1] != null)
				{
					countdownSpr.loadGraphic(graphs[loop - 1]);
					countdownSpr.screenCenter();

					tweenManager.num(1.0, 0.0, conductor.crochet * 0.001, {ease: FlxEase.cubeInOut}, function(v:Float)
					{
						countdownSpr.alpha = v;
					});
				}

				if (sounds[loop - 1] != null)
				{
					var countdownSound:FlxSound = FlxG.sound.load(sounds[loop - 1], false);
					soundList.push(countdownSound);
					countdownSound.play();
				}
			}
		}, len + 1);
		tmr.manager = timerManager;
	}

	public function keyPress(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (!paused && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED))
		{
			var confirm:Bool = false;

			for (note in inputNotes)
			{
				if (note.canBeHit(songPosition, (safeFrames / 60.0) * 1000.0) && note.direction == dir)
				{
					confirm = true;

					hitNote(note);
				}
			}

			if (confirm)
			{
				var player = playerList[0];
				player.playAnimation(player.singList[dir], true);
				player.singTimer = (conductor.crochet * 0.001) * 1.5;

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
		var dir:Int = checkKeyCode(event.keyCode);

		if (!paused && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_RELEASED))
		{
			for (strum in controlledStrums)
			{
				strum.members[dir].playAnim(strum.members[dir].staticAnim);
			}
		}
	}

	private static final controls:Array<Control> = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];

	public function checkKeyCode(keyCode:Int = -1)
	{
		if (keyCode != -1)
		{
			for (control in controls)
			{
				for (key in control.keys)
				{
					if (key == keyCode)
						return controls.indexOf(control);
				}
			}
		}
		return -1;
	}

	public function startSong():Void
	{
		musicHandler.playChannel(0, 0.8, false);
		musicHandler.playChannel(1, false);

		conductor.sound = musicHandler.channels[0];
		conductor.active = true;
		conductor.followSoundSource = false;

		gameStarted = true;
		gameRestarted = false;
	}

	public function endSong():Void
	{
		conductor.sound = null;

		gameStarted = false;

		restartSong();
	}

	public function restartSong():Void
	{
		gameRestarted = true;

		conductor.position = -5000;
		conductor.active = false;

		score = 0;
		health = maxHealth / 2.0;
		misses = 0;

		ratingHits = 0.0;
		totalHits = 0;

		combo = 0;

		updateScoreText();

		activeNotes.forEachAlive(function(note:NoteSprite)
		{
			destroyNote(note.noteData);
		});

		hudCamera.flash(FlxColor.BLACK, 0.25);

		generateSong();

		startCountdown(startSong);
	}

	var _removeNotes:Array<Note> = [];

	override public function update(elapsed:Float)
	{
		if (notes.length > 0)
		{
			var spawnTime:Float = 3000 / songMeta.speed;

			for (i in 0...notes.length)
			{
				if (notes[i] == null)
					continue;

				if (notes[i].strumTime - songPosition <= spawnTime)
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

		activeNotes.forEachAlive(function(note:NoteSprite)
		{
			var distance:Float = (0.45 * (songPosition - note.noteData.strumTime) * songMeta.speed);

			var strumGroup:FlxTypedGroup<StrumNote> = strumList[note.noteData.side];
			var strumNote:StrumNote = strumGroup.members[note.noteData.direction];

			note.centerOverlay(strumNote, X);
			note.y = strumNote.y - distance;

			if (gameStarted && !gameRestarted)
			{
				if (!determineStrums(note.noteData) && note.noteData.strumTime - songPosition < 0)
				{
					hitNote(note.noteData);
				}
				else if (note.noteData.strumTime - songPosition < -300 && determineStrums(note.noteData))
				{
					missNote(note.noteData);
				}
			}
		});

		for (note in _removeNotes.splice(0, _removeNotes.length))
		{
			destroyNote(note);
		}

		health = FlxMath.bound(health, 0, maxHealth);

		comboGroup.forEachAlive(function(spr:FlxSprite)
		{
			spr.customData.set("actualAlpha", spr.customData.get("actualAlpha") - (elapsed * 5));
			spr.alpha = spr.customData.get("actualAlpha");

			if (spr.alpha <= 0.0)
				spr.kill();
		});

		ratingGroup.forEachAlive(function(spr:FlxSprite)
		{
			spr.customData.set("actualAlpha", spr.customData.get("actualAlpha") - (elapsed * 5));
			spr.alpha = spr.customData.get("actualAlpha");

			if (spr.alpha <= 0.0)
				spr.kill();
		});

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

			// health += rating.healthHit;
			health += 0.75;

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

		// health -= rating.healthLoss;
		health -= 7.5;

		combo = 0;

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

		ratingSpr.customData.set("actualAlpha", 1.0 + (conductor.crochet * 0.002));
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
				comboSpr.setPosition(ratingSpr.objRight() - (ratingSpr.width / 2), ratingSpr.objBottom() + 10);
			}
			else
			{
				comboSpr.setPosition(lastComboSpr.objRight() - 8, lastComboSpr.y);
			}

			comboSpr.scale.set(0.5, 0.5);
			comboSpr.updateHitbox();

			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y = -FlxG.random.int(140, 160);
			comboSpr.velocity.x = FlxG.random.float(-5, 5);

			comboSpr.customData.set("actualAlpha", 1.0 + (conductor.crochet * 0.001));
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
