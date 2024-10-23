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

	public var ratings:Array<Rating> = [
		new Rating("sick"),
		new Rating("good", -90.0, 90.0, 0.75, 300),
		new Rating("bad", -135.0, 135.0, 0.50, 150),
		new Rating("shit", -166.0, 166.0, 0.25, -200),
	];

	public var lastRating(get, never):Rating;

	function get_lastRating():Rating
		return ratings[ratings.length - 1];

	public var missRating = new Rating("miss", Math.NEGATIVE_INFINITY, Math.POSITIVE_INFINITY, -100, 1, ["missnote1"]);

	// // managers
	public var timerManager:FlxTimerManager;
	public var tweenManager:FlxTweenManager;

	public var soundList:Array<FlxSound> = [];

	// cameras
	public var hudCamera:FlxCamera;
	public var pauseCamera:FlxCamera;

	// signals
	public var inputPressSignal:FlxTypedSignal<Int->Void>;
	public var inputReleaseSignal:FlxTypedSignal<Int->Void>;

	public var hitNoteSignal:FlxTypedSignal<(Note, Bool)->Void>;

	// events stuff
	public var events:Array<EventData> = [];
	public var focusedPoint:String = "";

	// sprites
	public var stage:Stage;

	// // hud
	public var stats:StatsUI;

	public var comboGroup:FlxTypedContainer<FlxSprite>;
	public var ratingGroup:FlxTypedContainer<FlxSprite>;

	// // characters
	public var characterList:FlxTypedGroup<Character>;

	public var playerList:Array<Character> = [];
	public var spectatorList:Array<Character> = [];
	public var opponentList:Array<Character> = [];

	// // notes & strums
	public var activeNotes:FlxTypedGroup<NoteSprite>;
	public var sustainNotes:FlxTypedGroup<SustainNote>;
	public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

	public var notes:Array<Note> = [];
	public var inputNotes:Array<Note> = [];

	public var controlledStrums:Array<FlxTypedGroup<StrumNote>> = [];

	public function new(folder:String = "", chartFile:String = "", isStory:Bool = false)
	{
		super();

		FlxG.fixedTimestep = false;

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
			timerManager.active = true;
			tweenManager.active = true;

			if (conductor.sound != null)
				conductor.resyncPosition();

			for (sound in soundList)
				sound.resume();

			paused = false;

			for (action in pauseMenu.actions)
			{
				action.active = false;
			}

			pauseCamera.bgColor.alphaFloat = 0.0;
			pauseCamera.visible = false;
			@:privateAccess
			if (!pauseMenu._songRestarted)
			{
				conductor.active = true;

				for (channel in musicHandler.channels)
				{
					if (channel.exists)
					{
						if (channel.ID == 0)
							musicHandler.resumeChannel(0, 0.8, false);
						else
							musicHandler.resumeChannel(channel.ID, false);
					}
				}
			}
			else
				pauseMenu._songRestarted = false;
		};

		Controls.registerFunction(Control.PAUSE, JUST_PRESSED, function()
		{
			if (!paused && pauseMenu != null)
			{
				timerManager.active = false;
				tweenManager.active = false;

				musicHandler.pauseChannels();

				for (sound in soundList)
					sound.pause();

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

		var file:String = Assets.assetPath('data/songs/${folder.toLowerKebabCase()}/${chartFile.toLowerKebabCase()}.json');

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

		folder = folder.toLowerKebabCase();
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

		switch (songMeta.stage)
		{
			default:
				stage = new DadStage();
		}
		add(stage);

		characterList = new FlxTypedGroup<Character>();

		for (player in songMeta.characters.players)
		{
			var char:Character = new Character(0.0, 0.0, player);
			char.scrollFactor.set(0.95, 0.95);
			characterList.add(char);
			playerList.push(char);

			conductor.onBeat.add(function(beat:Int)
			{
				char.beatHit();
			});
		}

		for (opponent in songMeta.characters.opponents)
		{
			var char:Character = new Character(0.0, 0.0, opponent);
			char.scrollFactor.set(0.95, 0.95);
			characterList.add(char);
			opponentList.push(char);

			conductor.onBeat.add(function(beat:Int)
			{
				char.beatHit();
			});
		}

		stage.initializeStage([spectatorList, opponentList, playerList]);

		FlxG.camera.zoom = stage.defaultZoom;

		generateSong();

		activeNotes = new FlxTypedGroup<NoteSprite>();
		activeNotes.camera = hudCamera;
		for (i in 0...15)
			activeNotes.add(new NoteSprite());
		activeNotes.killMembers();

		sustainNotes = new FlxTypedGroup<SustainNote>();
		sustainNotes.camera = hudCamera;
		for (i in 0...15)
			sustainNotes.add(new SustainNote());
		sustainNotes.killMembers();

		for (i in 0...(chartData.strumList?.list?.length ?? 2))
		{
			createStrum(FlxG.width / 2);
		}

		add(sustainNotes);
		add(activeNotes);

		createHUD();

		var controlledPlayers:Array<Int> = chartData.strumList?.controlledStrums ?? [1];
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
		stats = new StatsUI();
		stats.camera = hudCamera;
		stats.screenCenter();
		stats.y = FlxG.height * 0.9;
		add(stats);

		stats.getHealth = () -> return health;
		stats.getMaxHealth = () -> return maxHealth;

		stats.updateStatsText(score, misses, ratingHits / totalHits);

		conductor.onBeat.add(stats.beatHit);

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
		notes = Chart.readNotes(chartData);
		if (chartData.events != null)
		{
			events = [
				for (event in chartData.events)
					{
						name: event.name,
						time: event.time,
						contexts: [for (context in event.contexts) context]
					}
			];
		}
		else
			events = [];

		for (note in notes) // artificial increase
		{
			if (note.sustain > conductor.stepCrochet)
				note.sustain += conductor.stepCrochet;
		}

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

		var tmr:FlxTimer = new FlxTimer(timerManager);
		tmr.start(conductor.crochet * 0.001, function(tmr)
		{
			var loop:Int = tmr.loops - tmr.loopsLeft;
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
	}

	public function keyPress(event:KeyboardEvent)
	{
		var dir:Int = checkKeyCode(event.keyCode);

		if (!paused && dir != -1 && FlxG.keys.checkStatus(event.keyCode, JUST_PRESSED))
		{
			var confirm:Bool = false;
			var maxSustain:Float = 0.0;

			var confirmedNotes:Array<Note> = [];
			for (note in inputNotes)
			{
				if (note.canBeHit(songPosition, (safeFrames / 60.0) * 1000.0) && note.direction == dir && determineStrums(note))
				{
					confirm = true;
					maxSustain = Math.max(maxSustain, note.sustain);

					confirmedNotes.push(note);
				}
			}
			confirmedNotes.sort((note1:Note, note2:Note) ->
			{
				return FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime);
			});

			var firstNote = confirmedNotes[0];

			if (firstNote != null)
				hitNote(firstNote);

			for (i in 1...confirmedNotes.length)
			{
				var note:Note = confirmedNotes[i];
				if (Math.abs(firstNote.strumTime - note.strumTime) < conductor.stepCrochet)
					hitNote(note);
				else
					break;
			}

			if (confirm)
			{
				var player = playerList[0];
				player.playAnimation(player.singList[dir], true);
				player.singTimer = Math.max(player.singTimer,
					Math.max((maxSustain * 0.001) + ((conductor.crochet / 2) * 0.001), (conductor.crochet * 0.001) * 1.5));

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

	public var controls:Array<Control> = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];

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
		for (channel in musicHandler.channels)
		{
			if (channel.exists)
			{
				if (channel.ID == 0)
					musicHandler.playChannel(0, 0.8, false);
				else
					musicHandler.playChannel(channel.ID, false);
			}
		}

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

		stats.updateStatsText(score, misses, ratingHits / totalHits);

		activeNotes.forEachAlive(function(note:NoteSprite)
		{
			destroyNote(note.noteData);
		});

		hudCamera.flash(FlxColor.BLACK, 0.25);

		generateSong();

		startCountdown(startSong);
	}

	var _removeNotes:Array<Note> = [];
	var _removeEvents:Array<EventData> = [];

	override public function update(elapsed:Float)
	{
		if (notes.length > 0)
		{
			var spawnTime:Float = 3000 / songMeta.speed;

			for (i in 0...notes.length)
			{
				var note:Note = notes[i];
				if (note == null)
					continue;

				if (note.strumTime - songPosition <= spawnTime)
				{
					var noteSpr:NoteSprite = activeNotes.recycle(NoteSprite, function()
					{
						return new NoteSprite(note);
					});

					noteSpr.visible = true;
					noteSpr.noteData = note;
					noteSpr.sustain = null;

					activeNotes.add(noteSpr);

					if (note.sustain > 0.0)
					{
						var sustainSpr:SustainNote = sustainNotes.recycle(SustainNote, function()
						{
							return new SustainNote(note, STRETCH, note.sustain * songMeta.speed);
						});
						noteSpr.sustain = sustainSpr;

						sustainSpr.noteData = note;
						sustainSpr.length = note.sustain * songMeta.speed;
						sustainSpr.clipRect = null;
						note.sustainActive = false;

						sustainNotes.add(sustainSpr);
					}

					_removeNotes.push(note);

					if (determineStrums(note) && !inputNotes.contains(note))
						inputNotes.push(note);
				}
				else
					break;
			}

			for (note in _removeNotes.splice(0, _removeNotes.length))
				notes.remove(note);
		}

		if (gameStarted && !gameRestarted)
		{
			for (event in events)
			{
				if (conductor.position > event.time)
					_removeEvents.push(event);
				else
					break;
			}

			for (event in _removeEvents)
			{
				events.remove(event);
				onEvent(event);
			}

			_removeEvents.splice(0, _removeEvents.length);
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
				if (note.noteData == null) // somehow
					return;

				if (!determineStrums(note.noteData) && note.noteData.strumTime - songPosition < 0)
				{
					hitNote(note.noteData);
				}
				else if (determineStrums(note.noteData))
				{
					var hittable:Bool = note.noteData.wasHit;

					if (note.noteData.sustainActive)
						hittable = songPosition < note.noteData.strumTime + note.noteData.sustain + conductor.stepCrochet;

					if (hittable && note.noteData.sustain > 0.0)
					{
						if (controls[note.noteData.direction].checkStatus(PRESSED))
						{
							hitNote(note.noteData);
						}
						else if (controls[note.noteData.direction].checkStatus(JUST_RELEASED))
						{
							if (songPosition > note.noteData.strumTime + note.noteData.sustain + lastRating.minTime
								&& songPosition < note.noteData.strumTime + note.noteData.sustain + lastRating.maxTime)
							{
								hitSustainEnd(note.noteData);
							}
							else
							{
								missNote(note.noteData);
							}
						}
					}

					if (note.exists
						&& !note.noteData.sustainActive
						&& note.noteData.strumTime - songPosition < -(lastRating.maxTime * 2.0))
						missNote(note.noteData);
				}
			}
		});

		sustainNotes.forEachAlive(function(note:SustainNote)
		{
			if (!determineStrums(note.noteData) || controls[note.noteData.direction].checkStatus(PRESSED))
			{
				var strumGroup:FlxTypedGroup<StrumNote> = strumList[note.noteData.side];
				var strumNote:StrumNote = strumGroup.members[note.noteData.direction];

				var center = strumNote.y + (Note.noteWidth / 2);

				var rect = FlxRect.get(0, 0, note.width / note.scale.x, note.height / note.scale.y);
				rect.y = (center - note.y) / note.scale.y;
				rect.height -= rect.y;

				note.clipRect = rect;
			}
		});

		for (note in _removeNotes.splice(0, _removeNotes.length))
		{
			destroyNote(note);
		}

		health = FlxMath.bound(health, 0, maxHealth);

		comboGroup.forEachAlive(function(spr:FlxSprite)
		{
			if (spr.customData.actualAlpha > 1.0)
				spr.customData.actualAlpha -= elapsed * 5.0;
			else
				spr.customData.actualAlpha -= elapsed * 2.0;
			spr.alpha = spr.customData.actualAlpha;

			if (spr.alpha <= 0.0)
				spr.kill();
		});

		comboGroup.sort((order:Int, combo1:FlxSprite, combo2:FlxSprite) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, combo1.alpha, combo2.alpha);
		});

		ratingGroup.forEachAlive(function(spr:FlxSprite)
		{
			if (spr.customData.actualAlpha > 1.0)
				spr.customData.actualAlpha -= elapsed * 5.0;
			else
				spr.customData.actualAlpha -= elapsed * 2.0;

			spr.alpha = spr.customData.actualAlpha;

			if (spr.alpha <= 0.0)
				spr.kill();
		});

		ratingGroup.sort((order:Int, rating1:FlxSprite, rating2:FlxSprite) ->
		{
			return FlxSort.byValues(FlxSort.ASCENDING, rating1.alpha, rating2.alpha);
		});

		updateCamera(elapsed);

		super.update(elapsed);
	}

	public function onEvent(event:EventData):Void
	{
		switch (event.name)
		{
			case "Focus Camera":
				{
					focusedPoint = event.contexts[0];
					trace(focusedPoint);
				}
		}
	}

	public function updateCamera(elapsed:Float):Void
	{
		if (stage.cameraPoints.exists(focusedPoint))
		{
			var ratio:Float = 2.4 * elapsed * stage.cameraSpeed;

			var target:FlxPoint = stage.cameraPoints.get(focusedPoint).clone().subtract(FlxG.width / 2, FlxG.height / 2);

			FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, target.x, ratio);
			FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, target.y, ratio);

			target.put();
		}
	}

	public function hitNote(note:Note)
	{
		var canRemoveNote:Bool = false;

		if (determineStrums(note))
		{
			var diff:Float = conductor.position - note.strumTime;
			var rating:Rating = determineRatingByTime(diff);

			note.wasHit = true;

			if (!note.sustainActive)
			{
				var absDiff:Float = Math.abs(diff);
				var nextRating:Rating = ratings[ratings.indexOf(rating) + 1];

				var scoreAdd:Int = rating.score;
				if (absDiff > 10.0 && nextRating != null)
				{
					var scoreSub:Int = 0;
					scoreSub = FlxMath.remapToRange(absDiff, 10.0, nextRating.maxTime, 0, nextRating.score).floor();
					score += scoreAdd - scoreSub;
				}
				else
				{
					score += scoreAdd;
				}

				ratingHits += rating.accuracyFactor;
				totalHits++;

				// health += rating.healthHit;
				health += 0.75;

				combo++;

				popUpCombo(rating);
			}

			if (note.sustain > 0.0)
			{
				score += ((500 * (note.sustain / conductor.stepCrochet)) * FlxG.elapsed).floor();
				note.sustainActive = true;

				var strum:StrumNote = strumList[note.side].members[note.direction];

				strum.playAnim(strum.confirmAnim, strum.animation.curAnim.curFrame > 2);
			}

			stats.updateStatsText(score, misses, ratingHits / totalHits);
		}
		else if (strumList[note.side] != null)
		{
			var opponent = opponentList[0];
			opponent.playAnimation(opponent.singList[note.direction], true);
			opponent.singTimer = (conductor.crochet * 0.001) * 1.5;

			if (note.sustain > 0.0)
				note.sustainActive = true;

			var strum:StrumNote = strumList[note.side].members[note.direction];
			strum.playAnim(strum.confirmAnim, (!note.sustainActive || (note.sustainActive && strum.animation.curAnim.curFrame > 2)));

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

		if (note.sustainActive)
		{
			var endPosition:Float = note.strumTime + note.sustain;
			if (determineStrums(note))
				endPosition += conductor.stepCrochet;
			if (songPosition > endPosition)
				canRemoveNote = true;
			note.parent.visible = false;
		}

		if (note.sustain <= 0.0)
			canRemoveNote = true;

		if (canRemoveNote)
			destroyNote(note);
	}

	public function missNote(note:Note)
	{
		misses++;
		totalHits++;

		// health -= rating.healthLoss;
		health -= 7.5;

		combo = 0;

		stats.updateStatsText(score, misses, ratingHits / totalHits);

		var missSound:FlxSound = FlxG.sound.load(Assets.sfx('game/miss/missnote${FlxG.random.int(1, 3)}'), 0.4);
		soundList.push(missSound);
		missSound.play();

		destroyNote(note);
	}

	public function destroyNote(note:Note)
	{
		if (note == null)
			return;

		if (inputNotes.contains(note))
			inputNotes.remove(note);

		if (note.sustainParent != null)
		{
			note.sustainParent.kill();
			note.sustainParent.noteData = null;
		}

		if (note.parent != null)
		{
			note.parent.kill();
			note.parent.noteData = null;
		}
	}

	public function hitSustainEnd(note:Note):Void
	{
		if (determineStrums(note))
		{
			var diff:Float = conductor.position - (note.strumTime + note.sustain);
			var rating:Rating = determineRatingByTime(diff, 1.25);

			score += (rating.score / 2).floor();

			// health += rating.healthHit;
			health += 0.75;

			combo++;

			popUpCombo(rating);

			destroyNote(note);
		}
	}

	public function popUpCombo(rating:Rating):Void
	{
		var ratingSpr = ratingGroup.recycle(FlxSprite);
		ratingSpr.camera = hudCamera;
		ratingSpr.loadGraphic(Assets.image('game/combo/ratings/${rating.name}'));

		ratingSpr.scale.set(0.7, 0.7);
		ratingSpr.updateHitbox();

		ratingSpr.screenCenter();
		ratingSpr.x -= ratingSpr.width / 2;
		ratingSpr.y -= ratingSpr.height / 2;

		ratingSpr.acceleration.y = 550;
		ratingSpr.velocity.y = -FlxG.random.int(140, 175);
		ratingSpr.velocity.x = FlxG.random.int(0, 10) * FlxG.random.sign();

		ratingSpr.customData.actualAlpha = 1.0 + (conductor.crochet * 0.002);
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

			comboSpr.customData.actualAlpha = 1.0 + (conductor.crochet * 0.001);
			comboSpr.alpha = 1.0;

			comboGroup.add(comboSpr);

			lastComboSpr = comboSpr;
		}
	}

	private function determineRatingByTime(diff:Float = 0.0, mult:Float = 1.0):Rating
	{
		for (rating in ratings)
		{
			if (diff >= rating.minTime * mult && diff <= rating.maxTime * mult)
				return rating;
		}

		return missRating;
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

	override function startOutro(onOutroComplete:() -> Void):Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyRelease);

		musicHandler.clearChannels();
		conductor.sound = null;

		super.startOutro(onOutroComplete);
	}

	override function destroy():Void
	{
		conductor.clearCallbacks();

		super.destroy();
	}
}
