package states.menus;

class FreeplayState extends MainState
{
	#if CUSTOM_SONGS_ALLOWED
	public static final ENABLED_CUSTOM_SONGS:Bool = true;
	#else
	public static final ENABLED_CUSTOM_SONGS:Bool = false;
	#end

	public static var holdTimerStart:Float = 1.0;
	public static var holdTimerDelay:Float = 0.1;

	public static var selected:Int = 0;

	public var background:FlxSprite;

	public var songs:Array<SongDisplayData> = [];
	public var songGroup:FlxTypedGroup<Alphabet>;

	public var icons:FlxTypedGroup<IconSprite>;

	public var customSongText:Alphabet;

	public var controls:Array<ActionDigital> = [];

	public var holdTimer:FlxTimer;

	override function create()
	{
		if (!musicHandler.channels[0].alive)
			musicHandler.playChannel(0, "menus/freakyMenu", 0.8);
		conductor.sound = musicHandler.channels[0];

		background = new FlxSprite(Assets.image('menus/freeplayBG'));
		background.active = false;
		add(background);

		songGroup = new FlxTypedGroup<Alphabet>();
		add(songGroup);

		icons = new FlxTypedGroup<IconSprite>();
		add(icons);

		var index:Int = 0;
		for (week in WeekManager.weekList)
		{
			for (song in week.songList)
			{
				var songItem:Alphabet = new Alphabet(20 * (1 + index), 60 * (1 + index), song);
				songItem.ID = index;
				songItem.antialiasing = true;

				songGroup.add(songItem);

				if (index == selected)
					songItem.alpha = 1;
				else
					songItem.alpha = 0.6;

				var displayData:SongDisplayData = {};

				if (WeekManager.songHash.exists(song))
					displayData = WeekManager.songHash.get(song);

				songs[index] = {
					name: displayData.name ?? song,
					char: displayData.char ?? "face",
					color: displayData.color ?? FlxColor.WHITE
				};

				var icon:IconSprite = new IconSprite(displayData.char);
				icon.ID = index;
				icons.add(icon);

				index++;
			}
		}

		customSongText = new Alphabet(20 * (1 + index), 60 * (1 + index), "Custom Song");
		customSongText.ID = index;
		customSongText.antialiasing = true;

		if (index == selected)
			customSongText.alpha = 1;
		else
			customSongText.alpha = 0.6;

		songGroup.add(customSongText);

		controls.push(Controls.registerFunction(Control.ACCEPT, JUST_PRESSED, function()
		{
			for (control in controls)
				control.active = false;

			if (selected == customSongText.ID)
			{
				selectCustomSong();
			}
			else
			{
				musicHandler.clearChannels();
				conductor.sound = null;

				FlxG.switchState(() -> new PlayState(songs[selected].name, '${songs[selected].name.toLowerCase()}-hard'));
			}
		}));

		function pressKey(offset:Int)
		{
			if (songGroup.length > 1)
			{
				changeItem(offset);
				holdTimer.start(holdTimerStart, function(tmr:FlxTimer)
				{
					changeItem(offset);
					holdTimer.start(holdTimerDelay, (_) -> changeItem(offset), 0);
				});
			}
		}

		controls.push(Controls.registerFunction(Control.UI_UP, JUST_PRESSED, pressKey.bind(-1)));
		controls.push(Controls.registerFunction(Control.UI_DOWN, JUST_PRESSED, pressKey.bind(1)));

		controls.push(Controls.registerFunction(Control.UI_UP, JUST_RELEASED, function()
		{
			if (!Control.UI_DOWN.checkStatus(PRESSED))
				holdTimer.cancel();
		}));

		controls.push(Controls.registerFunction(Control.UI_DOWN, JUST_RELEASED, function()
		{
			if (!Control.UI_UP.checkStatus(PRESSED))
				holdTimer.cancel();
		}));

		holdTimer = new FlxTimer();

		super.create();
	}

	override function update(elapsed:Float)
	{
		songGroup.forEach(function(text:Alphabet)
		{
			if (text.ID == customSongText.ID)
				return;

			var mult:Float = 1.0;

			if (selected == customSongText.ID)
				mult = 1.2;

			var textPos:FlxPoint = FlxPoint.get();

			textPos.x = 90 + (35 * mult * (text.ID - selected));

			var center:Float = (FlxG.height / 2) - (text.height / 2);

			textPos.y = center + (165 * mult * (text.ID - selected));

			text.x = FlxMath.lerp(text.x, textPos.x, FlxMath.bound(elapsed * 7, 0, 1));
			text.y = FlxMath.lerp(text.y, textPos.y, FlxMath.bound(elapsed * 7, 0, 1));
		});

		var center:Float = (FlxG.height / 2) - (customSongText.height / 2);

		customSongText.x = FlxMath.lerp(customSongText.x, 90 + (35 * (customSongText.ID - selected)), FlxMath.bound(elapsed * 7, 0, 1));
		customSongText.y = FlxMath.lerp(customSongText.y, center + (165 * (customSongText.ID - selected)), FlxMath.bound(elapsed * 7, 0, 1));

		icons.forEach(function(icon:IconSprite)
		{
			var text:Alphabet = songGroup.members[icon.ID];

			icon.setPosition(text.objRight() + 30);
			icon.centerOverlay(text, Y);
		});

		super.update(elapsed);
	}

	public function changeItem(change:Int = 0)
	{
		if (songGroup.members[selected] != null)
			songGroup.members[selected].alpha = 0.6;

		selected = FlxMath.wrap(selected + change, 0, songGroup.length - 1);

		if (change != 0)
			FlxG.sound.play(Assets.sfx("menu/scrollMenu"), 0.5);

		if (songGroup.members[selected] != null)
			songGroup.members[selected].alpha = 1.0;
	}

	public function selectCustomSong():Void
	{
	}
}
