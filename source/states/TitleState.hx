package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import objects.Alphabet;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	public var blackBG:FlxSprite;

	// group before idle state
	public var startGroup:FlxTypedGroup<FlxSprite>;

	// group during idle state
	public var idleGroup:FlxTypedGroup<FlxSprite>;

	// text in the group
	public var textGroup:FlxTypedGroup<FlxSprite>;

	public var gfSprite:FlxSprite;
	public var fnfLogo:FlxSprite;

	override function create()
	{
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if (!initialized)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			else
				skipIntro();
		});

		blackBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);

		idleGroup = new FlxTypedGroup<FlxSprite>();
		add(idleGroup);

		startGroup = new FlxTypedGroup<FlxSprite>();
		add(startGroup);

		textGroup = new FlxTypedGroup<FlxSprite>();
		add(textGroup);

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

		idleGroup.add(gfSprite);
		idleGroup.add(fnfLogo);

		startGroup.add(blackBG);

		super.create();
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

		FlxG.camera.flash((Settings.getPref('flashing-lights', true) ? 0xFFFFFFFF : 0xFF000000), 4);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	private var danceDirection:Bool = false;

	private var lastBeat:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		danceDirection = !danceDirection;

		gfSprite.animation.play('dance' + (danceDirection ? 'Left' : 'Right'));
		fnfLogo.animation.play('bump', true);

		if (curBeat > lastBeat)
		{
			for (i in lastBeat...curBeat)
			{
				switch (i + 1)
				{
					case 1:
						createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					// credTextShit.visible = true;
					case 3:
						addMoreText('present');
					// credTextShit.text += '\npresent...';
					// credTextShit.addText();
					case 4:
						deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = 'In association \nwith';
					// credTextShit.screenCenter();
					case 5:
						createCoolText(['In association', 'with']);
					case 7:
						addMoreText('newgrounds');
					// ngSpr.visible = true;
					// credTextShit.text += '\nNewgrounds';
					case 8:
						deleteCoolText();
					// ngSpr.visible = false;
					// credTextShit.visible = false;

					// credTextShit.text = 'Shoutouts Tom Fulp';
					// credTextShit.screenCenter();
					case 9:
					// createCoolText([curWacky[0]]);
					// credTextShit.visible = true;
					case 11:
					// addMoreText(curWacky[1]);
					// credTextShit.text += '\nlmao';
					case 12:
						deleteCoolText();
					// credTextShit.visible = false;
					// credTextShit.text = "Friday";
					// credTextShit.screenCenter();
					case 13:
						addMoreText('Friday');
					// credTextShit.visible = true;
					case 14:
						addMoreText('Night');
					// credTextShit.text += '\nNight';
					case 15:
						addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

					case 16:
						skipIntro();
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
