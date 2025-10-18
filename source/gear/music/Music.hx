package gear.music;

import gear.assets.sound.SoundMetadata;

class Music extends FlxBasic
{
	public static var defaultTempo:Float = 100.0;
	public static var defaultTimeSignature:TimeSignatureStruct = {beat: 0, numerator: 4, denominator: 4};

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
	 * If true, the position will increment every frame to account for audio latency.
	 */
	public var syncWithGame:Bool = false;

	/**
	 * Current position of the sound in milliseconds.
	 */
	public var position:Float = 0.0;

	private var _lastPosition:Float = 0.0;

	public function new(soundFile:String, ?metadataFile:String)
	{
		super();

		load(soundFile, metadataFile);
	}

	public function load(soundFile:String, ?metadataFile:String):Void
	{
		if (metadataFile != null)
		{
			try
			{
				this.metadata = cast Json.parse(FlxG.assets.getTextUnsafe(metadataFile));
			}
			catch (e)
			{
				trace('Error parsing sound metadata file $metadataFile: $e');
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
		if (metadata == null)
		{
			// If there's no metadata, calculate steps using the simple tempo.
			// (tempo / 60 seconds) / 1000 ms = beats per millisecond
			var beatsPerMs = tempo / 60000;
			return position * beatsPerMs * 4; // 4 steps per beat
		}

		var tempoChanges:Array<TempoStruct> = metadata.tempoChanges ?? [];

		var stepTime:Float = 0.0;
		var totalBeats:Float = 0.0;
		var currentTempo:Float = metadata.tempo;

		for (change in tempoChanges)
		{
			var beatsInSegment = change.beat - totalBeats;
			if (beatsInSegment <= FlxMath.EPSILON) // Process multiple events at the same beat
			{
				currentTempo = change.newTempo;
				continue;
			}

			var msPerBeat = 60000.0 / currentTempo;
			var segmentDuration = beatsInSegment * msPerBeat;

			if (position < stepTime + segmentDuration)
			{
				// Position is within this segment.
				var beatsIntoSegment = (position - stepTime) / msPerBeat;
				return (totalBeats + beatsIntoSegment) * 4; // 4 steps per beat
			}

			stepTime += segmentDuration;
			totalBeats = change.beat;
			currentTempo = change.newTempo;
		}

		// Position is after the last tempo change event.
		var msPerBeat = 60000.0 / currentTempo;
		var beatsAfterLastEvent = (position - stepTime) / msPerBeat;
		return (totalBeats + beatsAfterLastEvent) * 4; // 4 steps per beat
	}

	function get_beatDec():Float
	{
		return stepDec / 4;
	}
}
