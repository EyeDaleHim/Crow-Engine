package states.menus;

class FreeplayState extends MainState
{
	public static var selected:Int = 0;

	public var background:FlxSprite;

	public var songs:Array<SongDisplayData> = [];
	public var songGroup:FlxTypedGroup<Alphabet>;

	public var icons:FlxTypedGroup<IconSprite>;

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

		Controls.registerFunction(Control.ACCEPT, JUST_PRESSED, function()
		{
			musicHandler.clearChannels();
			conductor.sound = null;

			FlxG.switchState(() -> new PlayState(songs[selected].name, '${songs[selected].name.toLowerCase()}-hard'));
		});

		Controls.registerFunction(Control.UI_UP, JUST_PRESSED, function()
		{
			if (songGroup.length > 1)
				changeItem(-1);
		});

		Controls.registerFunction(Control.UI_DOWN, JUST_PRESSED, function()
		{
			if (songGroup.length > 1)
				changeItem(1);
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		songGroup.forEach(function(text:Alphabet)
		{
			var textPos:FlxPoint = FlxPoint.get();

			textPos.x = 90 + (35 * (text.ID - selected));

			var center:Float = (FlxG.height / 2) - (text.height / 2);

			textPos.y = center + (165 * (text.ID - selected));

			text.x = FlxMath.lerp(text.x, textPos.x, FlxMath.bound(elapsed * 7, 0, 1));
			text.y = FlxMath.lerp(text.y, textPos.y, FlxMath.bound(elapsed * 7, 0, 1));
		});

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
}
