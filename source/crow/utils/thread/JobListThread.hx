package crow.utils.thread;

import sys.thread.Deque;
import sys.thread.Lock;

/**
 * A thread that processes a list of jobs sequentially.
 * 
 * It extends `CallbackThread` but is designed to be kept alive and reused
 * by adding jobs to it.
 */
class JobListThread extends CallbackThread
{
	private var _queue:Deque<() -> Void>;
	private var _lock:Lock;

	public function new(?immediately:Bool = false, ?name:String)
	{
		_queue = new Deque();
		_lock = new Lock();

		super(processQueue, immediately, name);
	}

	/**
	 * Adds a job to the queue.
	 * @param job The function to execute.
	 */
	public function add(job:() -> Void):Void
	{
		if (debug)
			trace('[Thread:$name] Added job to queue.');
		_queue.add(job);
	}

	/**
	 * Blocks the calling thread until all currently queued jobs are finished.
     * 
     * In other words, this pauses the calling thread (commonly the main thread).
	 */
	public function wait():Void
	{
		_queue.add(() -> _lock.release());
		_lock.wait();
	}

	/**
	 * Stops the thread gracefully after finishing current jobs.
	 */
	public function stop():Void
	{
		_queue.add(null);
	}

	/**
	 * Resets the progress counters.
	 * @param total The total number of items to process.
	 */
	public function resetProgress(total:Int):Void
	{
		if (debug)
			trace('[Thread:$name] Resetting progress. Total: $total');
		_currentProgress = 0;
		_totalProgress = total;
	}

	/**
	 * Increments the current progress by 1.
	 */
	public function incrementProgress():Void
	{
		if (debug)
			trace('[Thread:$name] Incrementing progress. ($_currentProgress/$_totalProgress)');
		_currentProgress++;

		update();
	}

	private function processQueue():Void
	{
		while (true)
		{
			var job = _queue.pop(true);
			if (job == null)
				break;

			job();
		}
	}
}
