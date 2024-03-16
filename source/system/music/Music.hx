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

	public function safePlayInst(embeddedSound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void)
	{
		if (inst.playing)
			return;
		playInst(embeddedSound, volume, looped, onComplete);
	}

	public function playInst(embeddedSound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void)
	{
		inst.loadEmbedded(Assets.music(embeddedSound), true, false, onComplete);

		inst.volume = volume;
		inst.play();
	}

	public function addVocalAndPlay(embeddedSound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void, followInst:Bool = true)
	{
		var vocal:FlxSound = FlxG.sound.list.recycle(FlxSound).loadEmbedded(Assets.music(embeddedSound), looped, false, onComplete);
		vocal.persist = true;
		vocal.volume = volume;
		if (followInst)
			vocal.time = inst.time;
		vocal.play();

		FlxG.sound.list.add(vocal);
	}

	public function stop()
	{
		if (inst?.playing)
			inst.stop();
		for (vocal in vocalList)
			vocal?.stop();
	}
}
