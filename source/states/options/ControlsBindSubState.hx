package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import objects.ui.Alphabet;
import utils.InputFormat;

class ControlsBindSubState extends MusicBeatSubState
{
	private var bind:String;
	private var keyIndex:Int = 0;

	public var background:FlxSprite;
	public var instructions:Alphabet;
	public var key:FlxText;

	public var backKey:FlxText;
	public var acceptKey:FlxText;

	override public function new(bind:String, keyIndex:Int)
	{
		super();

		this.bind = bind;
		this.keyIndex = keyIndex;

		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0.6;
		add(background);

		instructions = new Alphabet(0, 175, "Press any key", true);
		instructions.screenCenter(X);
		add(instructions);

		@:privateAccess
		key = new FlxText(0, 175, 0, InputFormat.format(Controls.instance.LIST_CONTROLS.get(bind).__keys[keyIndex]).toUpperCase(), 82);
		key.setFormat(Paths.font("vcr.ttf"), 82, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		key.borderSize = 4;
		key.screenCenter(XY);
		add(key);
	}

	public var selectedBind:FlxKey = 0;
	public var heldBind:Float = 0.0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		heldBind = Math.max(0, heldBind - elapsed);

		if (FlxG.keys.firstJustPressed() != -1)
		{
			if (InputFormat.matchesInput(FlxG.keys.firstJustPressed()) && FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]) != true)
			{
				selectedBind = FlxG.keys.firstJustPressed();
				
				@:privateAccess
				key.text = InputFormat.format(selectedBind).toUpperCase();
				key.screenCenter(XY);

				FlxG.sound.play("assets/sounds/menu/scrollMenu.ogg");
			}
		}

		if (FlxG.keys.justPressed.ESCAPE)
			acceptControls();

		if(FlxG.keys.justPressed.BACKSPACE)
			closeControls();
	}

	private function closeControls():Void
	{
		FlxG.state.persistentUpdate = true;
		close();
	}

	private function acceptControls():Void
	{
		var originalKeys:Array<FlxKey> = Settings.grabKey(bind, [NONE, NONE]);
		originalKeys[keyIndex] = (Std.int(selectedBind) <= 0 ? NONE : selectedBind);

		Settings.changeKey(bind, originalKeys);
		@:privateAccess
		Controls.instance.LIST_CONTROLS.get(bind).__keys[keyIndex] = (Std.int(selectedBind) <= 0 ? NONE : selectedBind);
		closeControls();
	}
}