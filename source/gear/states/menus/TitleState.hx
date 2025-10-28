package gear.states.menus;

import gear.states.internals.BaseMenuState;

class TitleState extends BaseMenuState
{
	private var randomPair:Array<String>;
	private var lastBeatHit:Int = -1;

	public function new()
	{
		super();

		Main.assets.loadContext("persistent");
		Main.assets.loadContext("title");

		menuMusic = new Music("music/menu/main");
		menuMusic.onBeat.add(onBeat);
		add(menuMusic);

		try
		{
			menuMetadata = cast Main.assets.json('data/menus/title');
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		if (Reflect.hasField(menuMetadata, "randomTextPairs"))
		{
			final randomTextPairs:Array<Array<String>> = Reflect.field(menuMetadata, "randomTextPairs");
			if (randomTextPairs != null && randomTextPairs.length > 0)
				randomPair = FlxG.random.getObject(randomTextPairs);
		}

		buildMenu();

		FlxTimer.wait(1, () ->
		{
			menuMusic.play();
			menuMusic.soundObject.fadeIn(4, 0, 0.7);
		});

		menuMusic.onBeat.add(onBeat);

		openCallback = onReturn;
	}

	public function onReturn():Void
	{
		menuMusic.onBeat.add(onBeat);
		FlxTimer.wait(1, () -> onEvent("skipIntro"));
	}

	private function onBeat(beat:Int):Void
	{
		if (beat <= lastBeatHit)
			return;

		for (b in (lastBeatHit + 1)...(beat + 1))
		{
			if (randomPair != null)
				logicState.set("randomText", randomPair);

			onEvent("beat", ["beat" => b]);
		}
		lastBeatHit = beat;
	}

	private function skipIntro():Void
	{
		onEvent("skipIntro");

		FlxG.camera.flash(FlxColor.WHITE, 1);
	}

	override public function update(elapsed:Float):Void
	{
		// Only handle intro-skipping input if the intro is active.
		if (menuEntities.exists("title_intro") && Main.input.isPressed("accept"))
			skipIntro();

		// Call the base class update method to handle menu input
		// after the intro is complete.
		super.update(elapsed);
	}
}
