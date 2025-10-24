package gear.states.menus;

import gear.states.internals.BaseMenuState;

class TitleState extends BaseMenuState
{
	// INTRO
	public var introScene:FlxContainer;

	public var introText:AnimatedText;
	public var associationSprite:FlxSprite;
	public var randomPair:Array<String>;

	private var lastBeatHit:Int = -1;

	public function new()
	{
		super();

		Main.assets.loadContext("persistent");
		Main.assets.loadContext("title");

		menuMusic = new Music("music/menu/main");
		menuMusic.onBeat.add(onBeat);
		add(menuMusic);

		var rawJson = FlxG.assets.getTextUnsafe('data/menus/title.json');
		if (rawJson == null)
			return;

		try
		{
			menuMetadata = cast Json.parse(JsonComment.removeComments(rawJson));
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		final randomTextPairs:Array<Array<String>> = Reflect.getProperty(menuMetadata, "randomTextPairs");
		if (randomTextPairs != null && randomTextPairs.length > 0)
		{
			randomPair = FlxG.random.getObject(randomTextPairs);
		}
		
		buildMenu();

		introScene = new FlxContainer();
		add(introScene);

		var blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		introScene.add(blackBG);

		introText = new AnimatedText(0, 0, "boldText");
		introText.fieldWidth = FlxG.width;
		introText.alignment = CENTER;
		introText.y = 200;
		introScene.add(introText);

		associationSprite = new FlxSprite();
		associationSprite.screenCenter(X);
		associationSprite.y = FlxG.height * 0.6;
		associationSprite.visible = false;
		introScene.add(associationSprite);

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
		FlxTimer.wait(1, () ->
		{
			skipIntro();
		});
	}

	private function onBeat(beat:Int):Void
	{
		if (beat <= lastBeatHit)
			return;

		for (b in (lastBeatHit + 1)...(beat + 1)) {
			onEvent("beat", ["beat" => b]);
		}
		lastBeatHit = beat;
	}

	private function skipIntro():Void
	{
		if (introScene == null || !introScene.exists)
			return;

		if (introScene != null)
		{
			introScene.destroy();
			introScene = null;
		}

		FlxG.camera.flash(FlxColor.WHITE, 1);
	}

	override public function update(elapsed:Float):Void
	{
		// Only handle intro-skipping input if the intro is active.
		if (Main.input.isPressed("accept"))
		{
			if (introScene != null && introScene.exists)
			{
				skipIntro();
			}
		}

		// Call the base class update method to handle menu input
		// after the intro is complete.
		super.update(elapsed);
	}

	/**
	 * Overrides the base `onEvent` to handle title-specific intro actions.
	 */
	override public function onEvent(eventName:String, ?args:Map<String, Dynamic>):Void
	{
		super.onEvent(eventName, args);

		if (menuMetadata?.logic?.listeners == null)
			return;

		for (listener in menuMetadata.logic.listeners)
		{
			if (listener.event != eventName)
				continue;

			// Temporarily add args to the state for evaluation
			if (args != null) for (key in args.keys()) logicState.set(key, args.get(key));

			final conditionMet = PredicateEvaluator.evaluate(listener.condition, this.logicState);

			// Clean up temporary state
			if (args != null) for (key in args.keys()) logicState.remove(key);

			if (!conditionMet)
				continue;

			for (action in listener.actions)
			{
				switch (action.type)
				{
					case "set_intro_text":
						introText.text = action.values.join("\n");
					case "add_intro_text":
						introText.text += "\n" + action.values.join("\n");
					case "wipe_intro_text":
						introText.text = "";
					case "use_random_text":
						if (randomPair != null && action.values != null)
						{
							final index = Std.parseInt(action.values[0]);
							if (index >= 0 && index < randomPair.length)
								introText.text += randomPair[index];
						}
					case "set_association_sprite":
						associationSprite.visible = (action.values[1] == "true");
						if (associationSprite.visible && action.values[0] != null && action.values[0] != "")
							associationSprite.loadGraphic(action.values[0]);
					case "skip_intro":
						skipIntro();
				}
			}
		}
	}
}
