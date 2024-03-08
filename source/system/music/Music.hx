package system.music;

// helper class
class Music extends FlxSoundGroup
{
    public var inst:FlxSound;
    public var vocalList:Array<FlxSound> = [];

    public function new()
    {
        super();

        inst = FlxG.sound.list.recycle(FlxSound);
        FlxG.sound.list.add(inst);
        add(inst);
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

        vocal.volume = volume;
        if (followInst)
            vocal.time = inst.time;
        vocal.play();
    }
}