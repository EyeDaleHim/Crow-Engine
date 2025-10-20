package gear.states.menus;

class TitleState extends MainState
{
	// INTRO
	/**
	 * The components contained for the intro in this scene.
	 * Only plays once during bootup and can be skipped.
	 */
   	public var introScene:FlxContainer;

	public var background:FlxSprite;
	public var testText:AnimatedText;

	public function new()
	{
		super();

		Main.assets.loadContext("title");

		// load music as test
		menuMusic = new Music("music/menu/main");
		menuMusic.play();
		add(menuMusic);

		testText = new AnimatedText(70, 70, "boldText", "abcdefghijklmnop\nqrstuvwxyz");
		testText.alignment = CENTER;
		add(testText);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
