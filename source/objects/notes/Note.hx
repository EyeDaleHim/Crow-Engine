package objects.notes;

class Note
{
	public static final noteWidth:Float = 160 * 0.7;

	public var strumTime:Float = 0.0;
	public var direction:Int = 0;
	public var side:Int = 0;
	public var type:String = "";
	public var sustain:Float = 0.0;

	public var wasHit:Bool = false;

	public var startedSustain:Float = 0.0;

	public var sustainActive:Bool = false;

	public var parent:NoteSprite;
	public var sustainParent:SustainNote;

	public function new(strumTime:Float = 0.0, direction:Int = 0, side:Int = 0, type:String = "", sustain:Float = 0.0)
	{
		this.strumTime = strumTime;
		this.direction = direction;
		this.side = side;
		this.type = type;
		this.sustain = sustain;

		startedSustain = sustain;
	}

	inline public function canBeHit(position:Float, safeZone:Float, ?earlyMult:Float = 1.0, ?lateMult:Float = 1.0):Bool
	{
		return (strumTime > (position - safeZone) * earlyMult && strumTime < (position + safeZone) * lateMult);
	}

	public function toString():String
	{
		return '{strumTime : $strumTime, direction : $direction, side : $side, type : \'$type\', sustain : $sustain, sustainActive: $sustainActive}';
	}
}
