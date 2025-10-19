package gear.states.menus;

class TitleState extends MainState
{
	// INTRO
	/**
	 * The components contained for the intro in this scene.
	 * Only plays once during bootup and can be skipped.
	 */
   	public var introScene:FlxContainer;

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
