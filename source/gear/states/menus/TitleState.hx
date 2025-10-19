package gear.states.menus;

class TitleState extends MainState
{
	/**
	 * 
	 */
   // public var 

	public function new()
	{
		super();

		Assets.loadContext("title");

		// load music as test
		menuMusic = new Music("music/menu/main");
		menuMusic.play();
		menuMusic.onBeat.add((beat) ->
		{
			if (menuMusic.soundObject.playing)
			{
				trace('Beat: ${menuMusic.beat}, Step: ${menuMusic.step}');
			}
		});
		add(menuMusic);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
