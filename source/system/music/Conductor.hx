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
    public final onSection:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

    public var beat(null, default):Float = 0.0;
    public var step(null, default):Float = 0.0;
    public var section(null, default):Float = 0.0;

    public var lastBeat(null, default):Int = -1;
    public var lastStep(null, default):Int = -1;
    public var lastSection(null, default):Int = -1;

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

    override public function new()
    {
        super();
    }

    override public function update(elapsed:Float)
    {
        if (sound == null)
            position += (elapsed * 1000);
        else
            position = sound.time - offset;

        step = position / stepCrochet;
        beat = step / 4;
        section = beat / 4;

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

        if (lastSection != getSection())
        {
            lastSection = getSection().floor();
            onSection.dispatch(getSection().floor());
        }

        #if FLX_DEBUG
        if (canWatch)
        {
            FlxG.watch.addQuick("Conductor ID", ID);

            FlxG.watch.addQuick("", "");
            
            FlxG.watch.addQuick("Position", position.floor());
            FlxG.watch.addQuick("Beat", getBeat());
            FlxG.watch.addQuick("Step", getStep());
            FlxG.watch.addQuick("Section", getSection());
        }
        #end

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

    public function getSection(floor:Bool = true):Float
    {
        if (floor)
            return section.floor();
        return section;
    }

    public function clearCallbacks():Void
    {
        onStep.removeAll();
        onBeat.removeAll();
        onSection.removeAll();
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