package system.music;

class Conductor extends FlxBasic
{
	public static var list:Array<Conductor> = [];

	public var sound:FlxSound;

	public var position:Float = 0.0;
	public var offset:Float = 0.0;

	public var bpm:Float = 100;
	public var crochet(get, never):Float;
	public var stepCrochet(get, never):Float;

	public final onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public final onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public final onMeasure:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public var beat(null, default):Float = 0.0;
	public var step(null, default):Float = 0.0;
	public var measure(null, default):Float = 0.0;

	public var lastBeat(null, default):Int = -1;
	public var lastStep(null, default):Int = -1;
	public var lastMeasure(null, default):Int = -1;

	public var followSoundSource:Bool = true;

	public var syncBuffer:Float = 30.0;

	#if FLX_DEBUG
	public var canWatch:Bool = true;
	#end

	public static function createNewConductor(sound:FlxSound, bpm:Float = 100.0)
	{
		var newConductor:Conductor = new Conductor();
		newConductor.sound = sound;
		newConductor.bpm = bpm;
		newConductor.ID = list.length;

		list.push(newConductor);
	}

	override public function update(elapsed:Float)
	{
		if (active)
		{
			if (!followSoundSource)
				position += (elapsed * 1000);
			else if (sound != null)
				position = sound.time - offset;

			if (!followSoundSource && sound != null)
			{
				if (sound.time - offset > 0 && Math.abs(position - (sound.time - offset)) > syncBuffer)
				{
					trace('RESYNC! ${Math.abs(position - (sound.time - offset))}ms');
					position = sound.time - offset;
				}
			}

			step = position / stepCrochet;
			beat = step / 4;
			measure = beat / 4;

			if (lastBeat != getBeat())
			{
				lastBeat = getBeat().floor();
				onBeat.dispatch(getBeat().floor());
			}

			if (lastStep != getStep())
			{
				lastStep = getStep().floor();
				onStep.dispatch(getStep().floor());
			}

			if (lastMeasure != getMeasure())
			{
				lastMeasure = getMeasure().floor();
				onMeasure.dispatch(getMeasure().floor());
			}

			#if FLX_DEBUG
			if (canWatch)
			{
				FlxG.watch.addQuick("Conductor ID", ID);

				FlxG.watch.addQuick("", "");

				FlxG.watch.addQuick("Position", position.floor());
				FlxG.watch.addQuick("Measure/Beat/Step", [getMeasure(), getBeat(), getStep()]);
				FlxG.watch.addQuick("BPM", bpm);
			}
			#end
		}

		super.update(elapsed);
	}

	public function getBeat(floor:Bool = true):Float
	{
		if (floor)
			return beat.floor();
		return beat;
	}

	public function getStep(floor:Bool = true):Float
	{
		if (floor)
			return step.floor();
		return step;
	}

	public function getMeasure(floor:Bool = true):Float
	{
		if (floor)
			return measure.floor();
		return measure;
	}

	public function clearCallbacks():Void
	{
		onStep.removeAll();
		onBeat.removeAll();
		onMeasure.removeAll();
	}

	function get_crochet():Float
	{
		return ((60 / bpm) * 1000);
	}

	function get_stepCrochet():Float
	{
		return crochet / 4;
	}
}
