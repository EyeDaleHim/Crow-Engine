package crow.utils.thread;

import sys.thread.Thread;
import haxe.Timer;

/**
 * A wrapper for `Thread` to simplify multithreading and make it easier to use.
 * 
 * It is recommended to keep main-thread variables away from any of these created threads.
 */
class CallbackThread implements ICrowThread
{
	/**
	 * A listener that is called when the thread succeeds.
	 */
	public var onComplete:Void->Void;

	/**
	 * A listener that is called when the thread gets an error.
	 */
	public var onError:Dynamic->Void;

	/**
	 * A listener that is called when the thread reports progress.
	 */
	public var onProgress:(progress:Int, length:Int) -> Void;

	/**
	 * The name of the thread, useful for debugging.
	 */
	public var name(default, null):String;

	/**
	 * The execution time of the thread's job in seconds.
	 */
	public var executionTime(default, null):Float = 0.0;

	/**
	 * If true, logs start, completion, and error messages to the console.
	 */
	public var debug:Bool = true;

	private var thread:Thread;
	private var complete:Bool = false;
	private var error:Dynamic = null;

	private var _job:() -> Void;

	// Internal state to sync progress to main thread
	@:allow(crow.utils.thread.JobListThread)
	private var _currentProgress:Int = 0;
	@:allow(crow.utils.thread.JobListThread)
	private var _totalProgress:Int = 0;
	private var _lastReportedProgress:Int = -1;

	public function new(call:() -> Void, ?immediately:Bool = false, ?name:String)
	{
		this.name = name ?? UUID.generateV4();

		_job = () ->
		{
			if (debug)
				trace('[Thread:$name] Started.');

			var start = Timer.stamp();

			try
			{
				call();
			}
			catch (e:Dynamic)
			{
				if (debug)
					trace('[Thread:$name] Error: $e');
				throw e;
			}

			var end = Timer.stamp();
			executionTime = end - start;

			if (debug)
				trace('[Thread:$name] Finished in ${executionTime}s.');
		};

		if (immediately)
		{
			start();
		}
	}

	/**
	 * Checks the status of the thread and calls `onComplete` or `onError` if the thread has finished or encountered an error.
	 * This method should be called periodically from the main thread (e.g., in `FlxState.update()`)
	 * to process the results of the background thread.
	 * 
	 * You can also call this in other main thread functions like a timer, as long as it's associated with the main thread.
	 */
	public function update():Void
	{
		if (onProgress != null && _currentProgress != _lastReportedProgress)
		{
			if (debug)
				trace('[Thread:$name] Progress: $_currentProgress/$_totalProgress');
			
			onProgress(_currentProgress, _totalProgress);
			_lastReportedProgress = _currentProgress;
		}

		if (complete)
		{
			if (debug)
				trace('[Thread:$name] Complete.');

			if (onComplete != null)
			{
				onComplete();
			}
			complete = false; // Reset to prevent repeated calls
		}
		else if (error != null)
		{
			if (debug)
				trace('[Thread:$name] Error: $error');

			if (onError != null)
			{
				onError(error);
			}
			error = null; // Reset to prevent repeated calls
		}
	}

	public function start():Void
	{
		if (complete)
		{
			throw "Cannot restart a completed thread. Create a new instance.";
		}
		if (thread != null)
		{
			throw "Thread is already running.";
		}

		trace('[Thread:$name] Starting.');

		thread = Thread.create(() ->
		{
			try
			{
				_job();
				complete = true;
			}
			catch (e:Dynamic)
			{
				error = e;
			}
		});
	}
}
