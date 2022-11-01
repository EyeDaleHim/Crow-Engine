package music;

// please place this somewhere more appropriate ty
class EventManager {}

typedef EventInfo =
{
	var eventSections:Array<EventData>;
}

typedef EventData =
{
	var strumTime:Float;
	var arguments:Array<Dynamic>;
}
