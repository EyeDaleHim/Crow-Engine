package music;

import states.PlayState;

// please place this somewhere more appropriate ty
class EventManager
{
	public function callFromEvent(eventName:String)
	{
		var gameInstance:PlayState = PlayState.current;

		switch (eventName) {}
	}

	public function triggerEvent(event:EventData)
	{
		var gameInstance:PlayState = PlayState.current;

		switch (event.eventName)
		{
			case 'Change Stage':
				{}
		}
	}
}

typedef EventInfo = Array<EventData>;

typedef EventData =
{
	var strumTime:Float;
	var eventName:String;
	var arguments:Array<Dynamic>;
}
