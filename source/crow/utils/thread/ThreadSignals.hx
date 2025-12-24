package crow.utils.thread;

typedef ThreadSignalsImpl =
{
	/**
	 * A listener that is called when the thread succeeds.
	 */
	var ?onComplete:Void->Void;

	/**
	 * A listener that is called when the thread gets an error.
	 */
	var ?onError:Dynamic->Void;

	/**
	 * A listener that is called when the thread reports progress.
	 */
	var ?onProgress:(progress:Int, length:Int) -> Void;
};

@:forward
abstract ThreadSignals(ThreadSignalsImpl) from ThreadSignalsImpl to ThreadSignalsImpl
{
	public inline function new()
	{
		this = {};
	}

	public inline function complete(func:Void->Void):ThreadSignals
	{
		this.onComplete = func;
		return this;
	}

	public inline function error(func:Dynamic->Void):ThreadSignals
	{
		this.onError = func;
		return this;
	}

	public inline function progress(func:(progress:Int, length:Int) -> Void):ThreadSignals
	{
		this.onProgress = func;
		return this;
	}
}
