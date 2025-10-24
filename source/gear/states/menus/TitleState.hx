package gear.states.menus;

import gear.assets.metadata.menus.TitleIntroMetadata;
import gear.states.internals.BaseMenuState;

class TitleState extends BaseMenuState
{
	// INTRO
	public var introMetadata:TitleIntroMetadata;

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
		menuMusic.onBeat.add(introBeatHit);
		add(menuMusic);

		// Load the intro sequence from the JSON file.

		var rawJson = FlxG.assets.getTextUnsafe('data/menus/title.json');
		if (rawJson == null)
			return;

		try
		{
			introMetadata = cast Json.parse(JsonComment.removeComments(rawJson));
			menuMetadata = introMetadata; // Assign to the base class property.
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		if (introMetadata != null && introMetadata.randomTextPairs != null && introMetadata.randomTextPairs.length > 0)
		{
			randomPair = FlxG.random.getObject(introMetadata.randomTextPairs);
		}

		// Build the main menu elements (decorations and layout) immediately.
		buildMenu();

		// But hide them until the intro is over.
		if (menuLayout != null)
			menuLayout.visible = false;

		for (entity in menuEntities)
		{
			entity.visible = false;
		}

		// Setup the scene for intro elements.
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

		menuMusic.onBeat.add((beat) ->
		{
			// Forward beat events to entities managed by the menu state.
			for (entity in menuEntities)
			{
				entity.onEvent("beat", beat);
			}
		});

		openCallback = onReturn;
	}

	public function onReturn():Void
	{
		menuMusic.onBeat.add((beat) ->
		{
			for (entity in menuEntities)
			{
				entity.onEvent("beat", beat);
			}
		});

		FlxTimer.wait(1, () ->
		{
			skipIntro();
		});
	}

	public function introBeatHit(curBeat:Int)
	{
		if (introMetadata == null || curBeat <= lastBeatHit)
			return;

		for (beat in (lastBeatHit + 1)...(curBeat + 1))
		{
			for (event in introMetadata.beatEvents)
			{
				if (event.beat == beat)
				{
					for (action in event.actions)
					{
						if (action.useRandomText != null && randomPair != null)
						{
							final lineIndex = action.useRandomText;
							if (lineIndex >= 0 && lineIndex < randomPair.length)
							{
								final chosenText = randomPair[lineIndex];
								introText.text += chosenText;
							}
						}
						else if (action.setText != null)
						{
							introText.text = action.setText.join("\n");
						}

						if (action.addText != null)
						{
							introText.text += "\n" + action.addText;
						}

						if (action.wipeText == true)
						{
							introText.text = "";
						}

						if (action.associationSprite != null)
						{
							final spriteInfo = action.associationSprite;
							if (spriteInfo.visible)
							{
								// Load graphic, set visible, and update hitbox.
								associationSprite.loadGraphic(spriteInfo.key);
								associationSprite.scale.set(0.8, 0.8);
								associationSprite.updateHitbox();
								associationSprite.screenCenter(X);
								associationSprite.visible = true;
							}
							else
							{
								associationSprite.visible = false;
							}
						}
					}

					if (event.killIntro == true)
					{
						skipIntro();
						return; // Stop processing any more beats.
					}
					break; // Found and processed the event for this beat.
				}
			}
		}

		lastBeatHit = curBeat;
	}

	private function skipIntro():Void
	{
		if (introScene == null || !introScene.exists)
			return;

		menuMusic.onBeat.remove(introBeatHit);

		if (introScene != null)
		{
			introScene.destroy();
			introScene = null;
		}

		if (menuLayout != null)
		{
			menuLayout.visible = true;
		}

		for (entity in menuEntities)
		{
			entity.visible = true;
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
}
