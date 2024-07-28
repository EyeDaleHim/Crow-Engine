package substates;

class MainSubState extends FlxSubState
{
	public var musicHandler(get, never):Music;
	public var conductor(get, never):Conductor;

	function get_musicHandler()
	{
		return FlxG.plugins.get(Music);
	}

	function get_conductor()
	{
		return FlxG.plugins.get(Conductor);
	}
}
