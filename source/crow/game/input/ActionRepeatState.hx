package crow.game.input;

class ActionRepeatState
{
	public var timeUntilNextRepeat:Float = 0;
	public var isRepeating:Bool = false;

	public function new() {}

	public function reset()
	{
		timeUntilNextRepeat = 0;
		isRepeating = false;
	}
}