package states;

class MainState extends FlxState
{
	public var musicHandler(get, never):Music;
	public var conductor(get, never):Conductor;

	override function create()
	{
		FlxG.plugins.addIfUniqueType(new Music());
		FlxG.plugins.addIfUniqueType(new Conductor());

		FlxG.console.registerObject("musicHandler", musicHandler);

		if (Conductor.list[0] == null)
			Conductor.createNewConductor(musicHandler.channels[0], 102);
	}

	function get_musicHandler()
	{
		return FlxG.plugins.get(Music);
	}

	function get_conductor()
	{
		return FlxG.plugins.get(Conductor);
	}

	override function startOutro(onOutroComplete:()->Void)
	{
		for (control in Controls.actions)
		{
			if (!control.persist)
			{
				control.destroy();
				Controls.actions.remove(control);
			}
		}

		super.startOutro(onOutroComplete);
	}
}
