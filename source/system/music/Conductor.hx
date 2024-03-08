package system.music;

class Conductor extends FlxBasic
{
    public static var list:Array<Conductor> = [];

    public var sound:FlxSound;

    public var position:Float = 0.0;
    public var offset:Float = 0.0;

    public var bpm(default, set):Float = 100;
    public var crochet(default, null):Float = 0.0;
    public var stepCrochet(default, null):Float = 0.0;

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
    public var addOnWatch:Bool = false;
    #end

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
        if (addOnWatch)
        {
            FlxG.watch.addQuick("Conductor ID", ID);

            FlxG.watch.addQuick("", "");
            
            FlxG.watch.addQuick("Position", position);
            FlxG.watch.addQuick("Beat [Floored, Current]", [getBeat(), getBeat(false)]);
            FlxG.watch.addQuick("Step [Floored, Current]", [getStep(), getStep(false)]);
            FlxG.watch.addQuick("Section [Floored, Current]", [getSection(), getSection(false)]);
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
            step.floor();
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

    function set_bpm(newBPM:Float):Float
    {
        bpm = newBPM;

        crochet = ((60 / bpm) * 1000);
        stepCrochet = crochet / 4;

        return newBPM;
    }
}