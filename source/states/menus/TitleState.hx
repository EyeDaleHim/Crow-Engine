package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import objects.Alphabet;
import openfl.Assets as OpenFlAssets;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	private var control:Bool = false;

	public var blackBG:FlxSprite;

	// group before idle state
	public var startGroup:FlxTypedGroup<FlxSprite>;

	// group during idle state
	public var idleGroup:FlxTypedGroup<FlxSprite>;

	// text in the group
	public var textGroup:FlxTypedGroup<FlxSprite>;

	public var newgroundsLogo:FlxSprite;

	public var gfSprite:FlxSprite;
	public var fnfLogo:FlxSprite;
	public var enterText:FlxSprite;

	public var introText:Array<String> = [];

	override function create()
	{
		introText = FlxG.random.getObject(getIntroText());

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			// dumb but quick shortcut for restarting a game through code
			initialized = !(FlxG.sound.music == null);

			if (!initialized)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.sound.music.fadeIn(4, 0, 0.7);

				Conductor.changeBPM(102);
			}
			else
				skipIntro();

			control = true;
		});

		FlxSprite.defaultAntialiasing = Settings.getPref('antialiasing', true);

		blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);

		idleGroup = new FlxTypedGroup<FlxSprite>();
		add(idleGroup);

		startGroup = new FlxTypedGroup<FlxSprite>();
		add(startGroup);

		textGroup = new FlxTypedGroup<FlxSprite>();
		add(textGroup);

		newgroundsLogo = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('title/newgrounds_logo'));
		newgroundsLogo.antialiasing = Settings.getPref('antialiasing', true);

		newgroundsLogo.scale.set(0.8, 0.8);
		newgroundsLogo.updateHitbox();
		newgroundsLogo.screenCenter(X);
		newgroundsLogo.visible = false;

		fnfLogo = new FlxSprite(-150, -100);
		fnfLogo.antialiasing = Settings.getPref('antialiasing', true);

		fnfLogo.frames = Paths.getSparrowAtlas('title/logoBumpin');
		fnfLogo.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		fnfLogo.animation.play('bump');
		fnfLogo.updateHitbox();

		gfSprite = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfSprite.antialiasing = Settings.getPref('antialiasing', true);
		gfSprite.frames = Paths.getSparrowAtlas('title/gfDanceTitle');

		var leftIndice:Array<Int> = Tools.numberArray(0, 14);
		leftIndice.unshift(30);

		gfSprite.animation.addByIndices('danceLeft', 'gfDance', leftIndice, "", 24, false);
		gfSprite.animation.addByIndices('danceRight', 'gfDance', Tools.numberArray(15, 29), "", 24, false);
		gfSprite.animation.play('danceLeft', true);

		enterText = new FlxSprite(100, FlxG.height * 0.8);
		enterText.antialiasing = Settings.getPref('antialiasing', true);

		enterText.frames = Paths.getSparrowAtlas('title/titleEnter');
		enterText.animation.addByPrefix('idle', 'Press Enter to Begin', 24);
		enterText.animation.addByPrefix('pressed', 'ENTER PRESSED', 24);
		enterText.animation.play('idle');
		enterText.updateHitbox();

		idleGroup.add(gfSprite);
		idleGroup.add(fnfLogo);
		idleGroup.add(enterText);

		startGroup.add(blackBG);
		startGroup.add(newgroundsLogo);

		super.create();
	}

	private function getIntroText():Array<Array<String>>
	{
		var fullText:String = OpenFlAssets.getText(Paths.file("data/introText", "txt", TEXT));

		var baseArray:Array<String> = fullText.split('\n');
		var mainArray:Array<Array<String>> = [];

		for (i in baseArray)
			mainArray.push(i.split('--'));

		return mainArray;
	}

	private function skipIntro():Void
	{
		for (sprite in startGroup.members)
		{
			if (sprite != null)
			{
				sprite.visible = false;
				startGroup.remove(sprite);
			}
		}

		for (text in textGroup.members)
		{
			if (text != null)
			{
				textGroup.remove(text);
			}
		}

		TitleState.initialized = true;

		FlxG.camera.flash((Settings.getPref('flashing-lights', true) ? 0xFFFFFFFF : 0xFF000000), 4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (control)
		{
			if (controls.getKey('ACCEPT', JUST_PRESSED))
			{
				if (!TitleState.initialized)
					skipIntro();
				else
				{
					enterText.animation.play('pressed');

					FlxG.camera.flash(0xFFFFFFFF, 1);
					FlxG.sound.play(Paths.sound('menu/confirmMenu'), 0.7);

					new FlxTimer().start(2, function(timer:FlxTimer)
					{
						MusicBeatState.switchState(new MainMenuState());
					});
				}
			}
		}

		if (FlxG.sound.music != null)
		{
			if (initialized)
			{
				if (FlxG.sound.music.volume <= 0.7)
					FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + (elapsed * 0.5), 0.7);
			}
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	private var danceDirection:Bool = false;

	private var lastBeat:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		danceDirection = !danceDirection;

		gfSprite.animation.play('dance' + (danceDirection ? 'Left' : 'Right'));
		fnfLogo.animation.play('bump', true);

		if (!initialized)
		{
			if (curBeat > lastBeat)
			{
				for (i in lastBeat...curBeat)
				{
					switch (i + 1)
					{
						case 1:
							createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
						case 3:
							addMoreText('present');
						case 4:
							deleteCoolText();
						case 5:
							createCoolText(['In association', 'with']);
						case 7:
							addMoreText('newgrounds');
							newgroundsLogo.visible = true;
						case 8:
							deleteCoolText();
							newgroundsLogo.visible = false;
						case 9:
							createCoolText([introText[0]]);
						case 11:
							addMoreText(introText[1]);
						case 12:
							deleteCoolText();
						case 13:
							addMoreText('Friday');
						case 14:
							addMoreText('Night');
						case 15:
							addMoreText('Funkin');
						case 16:
							skipIntro();
					}
				}
			}
		}

		lastBeat = curBeat;
	}

	private function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var textObject:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			textObject.screenCenter(X);
			textObject.y += (i * 60) + 200;
			startGroup.add(textObject);
			textGroup.add(textObject);
		}
	}

	private function addMoreText(text:String)
	{
		var textObject:Alphabet = new Alphabet(0, 0, text, true, false);
		textObject.screenCenter(X);
		textObject.y += (textGroup.length * 60) + 200;
		startGroup.add(textObject);
		textGroup.add(textObject);
	}

	private function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			startGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
}
