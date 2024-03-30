package system.music;

// helper class
class Music extends FlxBasic
{
	public var inst:FlxSound;
	public var vocalList:Array<FlxSound> = [];

	public function new()
	{
		super();

		inst = FlxG.sound.list.recycle(FlxSound);
		inst.persist = true;
		FlxG.sound.list.add(inst);
	}

	public function loadInst(sound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void)
	{
		if (inst == null)
		{
			inst = FlxG.sound.list.recycle(FlxSound);
			inst.persist = true;
			FlxG.sound.list.add(inst);
		}

		if (inst.playing)
			inst.stop();

		inst.loadEmbedded(Assets.music(sound), true, false, onComplete);
		inst.persist = true;
		inst.volume = volume;
	}

	public function playInst(?sound:Null<String>, volume:Float = 1.0, looped:Null<Bool> = null, ?onComplete:Void->Void)
	{
		if (sound != null)
		{
			if (inst.playing)
				return;
			@:privateAccess
			if (inst._sound == null)
				loadInst(sound, volume, looped, onComplete);
		}
		inst.looped = looped ?? inst.looped;

		inst.play(true);
	}

	public function loadVocal(sound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void, followInst:Bool = true)
	{
		var vocal:FlxSound = FlxG.sound.list.recycle(FlxSound).loadEmbedded(Assets.music(sound), looped, false, onComplete);
		vocal.persist = true;
		vocal.volume = volume;
		if (followInst)
			vocal.time = inst.time;

		FlxG.sound.list.add(vocal);
		vocalList.push(vocal);
	}

	public function playAllVocal(?sounds:Array<String>, volume:Float = 1.0, looped:Null<Bool> = null, ?onComplete:Void->Void)
	{
		for (i in 0...vocalList.length)
		{
			var vocal = vocalList[i];
			vocal.looped = looped ?? vocal.looped;

			vocal.play(true);
		}
	}

	public function stop(stopInst:Bool = true, stopVocals:Bool = true)
	{
		if (stopInst)
		{
			if (inst?.playing)
				inst.stop();
		}
		
		if (stopVocals)
		{
			for (vocal in vocalList)
				vocal?.stop();
		}
	}
}
