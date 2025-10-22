package gear.music;

import gear.assets.metadata.SoundMetadata;

class Music extends FlxBasic
{
	public static var defaultTempo:Float = 100.0;
	public static var defaultTimeSignature:TimeSignatureStruct = {beat: 0, numerator: 4, denominator: 4};

	/**
	 * The signal that dispatches when a new step happens.
	 */
	public var onBeat:FlxTypedSignal<Int->Void>;

	/**
	 * The signal that dispatches when a new beat happens.
	 */
	public var onStep:FlxTypedSignal<Int->Void>;

	/**
	 * The current beat of the sound, in integers.
	 */
	public var beat(get, never):Int;

	/**
	 * The current step of the sound, in integers.
	 */
	public var step(get, never):Int;

	/**
	 * The current beat of the sound, in decimals.
	 */
	public var beatDec(get, never):Float;

	/**
	 * The current step of the sound, in decimals.
	 */
	public var stepDec(get, never):Float;

	/**
	 * The sound object that is being played.
	 */
	public var soundObject:FlxSound;

	/**
	 * The metadata of the sound. Can be null!
	 */
	public var metadata:SoundMetadata;

	/**
	 * Current tempo of the sound.
	 */
	public var tempo:Float = defaultTempo;

	/**
	 * Current time signature of the sound.
	 */
	public var timeSignature:TimeSignatureStruct = defaultTimeSignature;

	/**
	 * If true, fields like tempo and timeSignature are updated depending on the
	 * position and `metadata` fields. If you are modifying these fields, you should
	 * put this on false.
	 */
	public var updateFields:Bool = true;

	/**
	 * If true, the position will try to compensate for granularity in-between audio updates.
	 */
	public var syncWithGame:Bool = false;

	/**
	 * Current position of the sound in milliseconds.
	 */
	public var position:Float = 0.0;

	private var _lastPosition:Float = 0.0;

	private var _lastBeat:Int = 0;
	private var _lastStep:Int = 0;

	private var _tempoMap:Array<{time:Float, beat:Float, tempo:Float}>;

	/**
	 * The amount of steps per beat.
	 */
	public static inline var STEPS_PER_BEAT:Int = 4;

	public function new(soundFile:String)
	{
		super();

		onBeat = new FlxTypedSignal<Int->Void>();
		onStep = new FlxTypedSignal<Int->Void>();

		load(soundFile);
	}

	public function load(soundFile:String):Void
	{
		if (soundFile != null)
		{
			try
			{
				final path = Path.join(['sounds', '$soundFile.json']);
				if (FlxG.assets.exists(path))
				{
					this.metadata = cast Json.parse(JsonComment.removeComments(FlxG.assets.getTextUnsafe(path)));
				}
			}
			catch (e)
			{
				trace('Error parsing sound metadata file $soundFile: $e');
				this.metadata = null;
			}
		}
		else
		{
			this.metadata = null;
		}

		soundObject = FlxG.sound.load(soundFile);

		if (this.metadata != null)
		{
			soundObject.volume = metadata.volume;
			soundObject.looped = metadata.looped;
		}

		_precalculateTempoMap();
	}

	public function pause():Void
	{
		soundObject.pause();
	}

	public function play():Void
	{
		soundObject.play();
	}

	public function stop():Void
	{
		_lastPosition = 0.0;

		soundObject.stop();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (soundObject.playing)
		{
			if (syncWithGame)
			{
				if (soundObject.time == _lastPosition)
				{
					position += elapsed * 1000;
				}
				else
				{
					position = soundObject.time;
				}

				_lastPosition = soundObject.time;
			}
			else
			{
				position = soundObject.time;
			}

			if (updateFields && metadata != null)
			{
				// Update tempo
				if (metadata.tempoChanges != null)
				{
					for (change in metadata.tempoChanges)
					{
						if (beatDec >= change.beat)
						{
							tempo = change.newTempo;
						}
					}
				}
				else if (metadata.tempo != null)
				{
					tempo = metadata.tempo;
				}

				// Update time signature
				if (metadata.timeSignatures != null)
				{
					for (change in metadata.timeSignatures)
					{
						if (beatDec >= change.beat)
						{
							timeSignature = change;
						}
					}
				}
				else if (metadata.timeSignature != null)
				{
					timeSignature = metadata.timeSignature;
				}
			}

			if (_lastBeat != beat)
			{
				onBeat.dispatch(beat);
			}

			if (_lastStep != step)
			{
				onStep.dispatch(step);
			}

			_lastBeat = beat;
			_lastStep = step;
		}
	}

	function get_beat():Int
	{
		return Math.floor(beatDec);
	}

	function get_step():Int
	{
		return Math.floor(stepDec);
	}

	// Get the current step in decimals
	function get_stepDec():Float
	{
		if (_tempoMap == null || _tempoMap.length == 0)
		{
			// If there's no metadata, calculate steps using the simple tempo.
			// (tempo / 60 seconds) / 1000 ms = beats per millisecond
			var beatsPerMs = tempo / 60000;
			return position * beatsPerMs * STEPS_PER_BEAT;
		}

		// Find the correct tempo segment using the pre-calculated map
		var segment = _tempoMap[0];
		for (i in 1..._tempoMap.length)
		{
			if (position < _tempoMap[i].time)
				break;
			segment = _tempoMap[i];
		}

		var msPerBeat = 60000 / segment.tempo;
		var beatsIntoSegment = (position - segment.time) / msPerBeat;
		return (segment.beat + beatsIntoSegment) * STEPS_PER_BEAT;
	}

	function get_beatDec():Float
	{
		return stepDec / STEPS_PER_BEAT;
	}

	private function _precalculateTempoMap()
	{
		if (metadata == null || metadata.tempo == null)
		{
			_tempoMap = null;
			return;
		}

		_tempoMap = [];
		_tempoMap.push({time: 0, beat: 0, tempo: metadata.tempo});

		var tempoChanges:Array<TempoStruct> = metadata.tempoChanges ?? [];
		if (tempoChanges.length == 0)
			return;

		// Sort by beat to ensure correct processing order
		tempoChanges.sort((a, b) -> a.beat < b.beat ? -1 : 1);

		var lastBeat:Float = 0;
		var lastTime:Float = 0;
		var lastTempo:Float = metadata.tempo;

		for (change in tempoChanges)
		{
			var beatsSinceLast = change.beat - lastBeat;
			if (beatsSinceLast <= 0)
				continue; // Skip same-beat changes, only use the last one

			lastTime += beatsSinceLast * (60000 / lastTempo);
			_tempoMap.push({time: lastTime, beat: change.beat, tempo: change.newTempo});
			lastBeat = change.beat;
			lastTempo = change.newTempo;
		}
	}
}
