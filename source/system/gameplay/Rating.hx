package system.gameplay;

class Rating
{
    public var name:String = "sick";

    public var maxTime:Float = 0.0;
    public var minTime:Float = 0.0;

    public var score:Int = 0;
    public var miss:Int = 0;

    public var accuracyFactor:Float = 1.0;

    public var sounds:Array<String> = [];

    public function new(name:String, minTime:Float = -45.0, maxTime:Float = 45.0, accuracyFactor:Float = 1.0, score:Int = 500, miss:Int = 0, ?sounds:Array<String>)
    {
        this.name = name;

        this.minTime = minTime;
        this.maxTime = maxTime;
        this.score = score;
        this.miss = miss;
        this.accuracyFactor = accuracyFactor;

        if (sounds == null)
            this.sounds = [];
        else
            this.sounds = sounds;
    }
}