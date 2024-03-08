package states;

class MainState extends FlxState
{
	public static var musicHandler(get, never):Music;
	public static var conductor(get, never):Conductor;

	override function create()
	{
        FlxG.plugins.addIfUniqueType(new Music());
		FlxG.plugins.addIfUniqueType(new Conductor());

        if (Conductor.list[0] == null)
            Conductor.createNewConductor(musicHandler.inst, 102);
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
