package crow.entities.managers;

import flixel.util.FlxTimer;

/**
 * Manages a collection of named `FlxTimer` objects for an entity.
 * This allows for easy tracking, retrieval, and cleanup of timers.
 */
class TimerManager implements IManager<FlxTimer>
{
	public var list(default, null):Map<String, FlxTimer>;

	public function new()
	{
		list = new Map<String, FlxTimer>();
	}

	/**
	 * Adds a timer to the manager. If a timer with the same name
	 * already exists, it will be canceled and replaced.
	 */
	public function add(name:String, timer:FlxTimer):Void
	{
		// If a timer with the same name exists, cancel it before replacing.
		if (list.exists(name))
		{
			final oldTimer = list.get(name);
			oldTimer.cancel();
			oldTimer.destroy();
		}
		list.set(name, timer);
	}

	/**
	 * Creates a new one-shot timer, adds it to the manager, and returns it.
	 * The timer will be automatically removed from the manager upon completion.
	 * @param name The unique name to identify the timer.
	 * @param time The duration of the timer in seconds.
	 * @param onComplete The function to call when the timer finishes.
	 * @return The created `FlxTimer` instance.
	 */
	public function wait(name:String, time:Float, ?onComplete:()->Void):FlxTimer
	{
		// Wrap the onComplete to also remove the timer from the manager.
		final onCompleteWrapper = (timer:FlxTimer) ->
		{
			if (onComplete != null)
			{
				onComplete();
			}
			remove(name); // Auto-remove on completion
		};

		final newTimer = new FlxTimer().start(time, onCompleteWrapper, 1);
		add(name, newTimer);
		return newTimer;
	}

	/**
	 * Creates a new looping timer, adds it to the manager, and returns it.
	 * The timer will be automatically removed from the manager upon completion if `loops` is finite.
	 * @param name The unique name to identify the timer.
	 * @param time The duration of each loop in seconds.
	 * @param loops The number of times the timer should loop. 0 for infinite loops.
	 * @param onComplete The function to call when the timer finishes (after all loops).
	 * @return The created `FlxTimer` instance.
	 */
    public function loop(name:String, time:Float, ?loops:Int = 0, ?onComplete:()->Void):FlxTimer
	{
		final onCompleteWrapper = (timer:FlxTimer) ->
		{
			if (onComplete != null)
			{
				onComplete();
			}
			if (loops != 0) // Only auto-remove if it's a finite loop
			{
				remove(name);
			}
		};

		final newTimer = new FlxTimer().start(time, onCompleteWrapper, loops);
		add(name, newTimer);
		return newTimer;
    }

	public function get(name:String):Null<FlxTimer>
	{
		return list.get(name);
	}

	/**
	 * Removes a timer from the manager and cancels it.
	 */
	public function remove(name:String):Bool
	{
		final timer = list.get(name);
		if (timer != null)
		{
			timer.cancel();
			timer.destroy();
		}
		return false;
	}

	/**
	 * Cancels and removes all managed timers.
	 */
	public function clear():Void
	{
		for (timer in list)
		{
			timer.cancel();
			timer.destroy();
		}
		list.clear();
	}
}
