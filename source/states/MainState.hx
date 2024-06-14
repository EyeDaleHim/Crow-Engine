package states;

class MainState extends FlxState
{
	public static var musicHandler(get, never):Music;
	public static var conductor(get, never):Conductor;

	override function create()
	{
        FlxG.plugins.addIfUniqueType(new Music());
		FlxG.plugins.addIfUniqueType(new Conductor());

		FlxG.console.registerObject("musicHandler", musicHandler);

        if (Conductor.list[0] == null)
            Conductor.createNewConductor(musicHandler.channels[0], 102);
	}

	static function get_musicHandler()
	{
		return FlxG.plugins.get(Music);
	}

	static function get_conductor()
	{
		return FlxG.plugins.get(Conductor);
	}
}
