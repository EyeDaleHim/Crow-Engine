package gear.states.menus;

import gear.states.internals.BaseMenuState;
import gear.assets.metadata.menus.TitleIntroMetadata;

class TitleState extends BaseMenuState
{
	// INTRO
	public var introScene:FlxContainer;

	public var introText:AnimatedText;

	public var randomPair:Array<String>;
	private var introMetadata:TitleIntroMetadata;
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
			introMetadata = cast Json.parse(JsonComment.removeComments(rawJson));
			menuMetadata = introMetadata;
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		if (introMetadata.randomTextPairs != null && introMetadata.randomTextPairs.length > 0)
		{
			randomPair = FlxG.random.getObject(introMetadata.randomTextPairs);
		}
		
		buildMenu();

		introScene = new FlxContainer();
		add(introScene);

		final blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		introScene.add(blackBG);

		introText = new AnimatedText(0, 0, "boldText");
		introText.fieldWidth = FlxG.width;
		introText.alignment = CENTER;
		introText.y = 200;
		introScene.add(introText);

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

		if (eventName != "beat" || introMetadata?.beatEvents == null)
			return;

		final beat:Int = args.get("beat");

		for (event in introMetadata.beatEvents)
		{
			if (event.beat != beat)
				continue;

			if (event.actions != null)
			{
				for (action in event.actions)
				{
					if (action.setText != null)
						introText.text = action.setText.join("\n");

					if (action.addText != null)
						introText.text += (introText.text == "" ? "" : "\n") + action.addText;

					if (action.wipeText == true)
						introText.text = "";

					if (action.useRandomText != null && randomPair != null)
					{
						final index = action.useRandomText;
						if (index >= 0 && index < randomPair.length)
							introText.text += randomPair[index];
					}

					if (action.associationSprite != null)
					{
						if (menuEntities.exists("association_sprite"))
							menuEntities.get("association_sprite").visible = action.associationSprite.visible;
					}
				}
			}

			if (event.killIntro == true)
				skipIntro();
		}
	}
}
