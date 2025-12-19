package crow.game.levels;

/**
 * Manages a transient session of levels (e.g. a Story Mode run).
 */
class Playlist
{
	/**
	 * The sequence of levels to play.
	 */
	public var queue:Array<Level>;

	public var currentIndex(default, null):Int = 0;

	public var length(get, never):Int;

	public function new(levels:Array<Level>)
	{
		this.queue = levels;
		this.currentIndex = 0;
	}

	public function getCurrent():Level
	{
		if (currentIndex >= 0 && currentIndex < queue.length)
			return queue[currentIndex];
		return null;
	}

	public function next():Bool
	{
		currentIndex++;
		return currentIndex < queue.length;
	}

	public function reset():Void
	{
		currentIndex = 0;
	}

	function get_length():Int
	{
		return queue.length;
	}
}
