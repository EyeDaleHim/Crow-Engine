package system.music;

// helper class
class Music extends FlxBasic
{
	public static var cacheLimit:Int = 4;

	public var channels:Array<FlxSound> = [];

	private var _loadIndex:Int = 0;

	public function new()
	{
		super();

		for (i in 0...cacheLimit)
		{
			var channel:FlxSound = new FlxSound();
			channel.persist = true;
			channel.kill();
			channel.ID = i;
			channels.push(channel);
			FlxG.sound.list.add(channel);
		}
	}

	public function loadChannel(sound:String, volume:Float = 1.0, looped:Bool = true, ?onComplete:Void->Void):FlxSound
	{
		var curChannel:FlxSound = channels[_loadIndex];

		if (curChannel == null)
		{
			if (curChannel != null)
				curChannel.stop();
			else
				curChannel = new FlxSound();
			curChannel.persist = true;
			curChannel.ID = _loadIndex;
			channels[_loadIndex] = curChannel;
			FlxG.sound.list.add(curChannel);
		}

		if (curChannel.playing)
			curChannel.stop();

		curChannel.loadEmbedded(Assets.music(sound), looped, false, onComplete);
		curChannel.persist = true;
		curChannel.volume = volume;

		curChannel.revive();

		_loadIndex++;

		return curChannel;
	}

	public function playChannel(channel:Int, ?sound:Null<String>, volume:Float = 1.0, looped:Null<Bool> = null, ?onComplete:Void->Void)
	{
		var curChannel:FlxSound = channels[channel];

		if (!curChannel?.exists)
		{
			curChannel = loadChannel(sound, volume, looped, onComplete);
		}

		curChannel.play(true);
	}

	public function resumeChannel(channel:Int, ?sound:Null<String>, volume:Float = 1.0, looped:Null<Bool> = null)
	{
		trace("resumed");
		var curChannel:FlxSound = channels[channel];

		if (!curChannel?.exists)
		{
			playChannel(channel, sound, volume, looped);
			return;
		}

		curChannel.resume();
	}

	public function clearChannels()
	{
		for (channel in channels)
		{
			if (channel != null)
			{
				channel.stop();
				channel.kill();
			}
		}

		for (channel in channels.splice(cacheLimit, channels.length))
		{
			channel.destroy();
			channel = null;
		}

		_loadIndex = 0;
	}

	public function pauseChannels()
	{
		trace("paused");
		for (channel in channels)
		{
			if (channel != null)
			{
				channel.pause();
			}
		}
	}
}
