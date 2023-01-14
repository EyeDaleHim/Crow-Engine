package states.options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;

class DescriptionHolder extends FlxTypedSpriteGroup<FlxSprite>
{
	public var text(default, set):String = '';
	public var targetAlpha:Float = 0.0;

	private var _background:FlxSprite;
	private var _text:FlxText;

	private var _controlledAlpha:Float = 0.0;

	public override function new()
	{
		super();

		_text = new FlxText(0, 0, 0, text, 16);
		_text.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, OUTLINE, FlxColor.fromRGBFloat(0, 0, 0, 0.8));
		_text.borderSize = 1.25;
		_text.fieldWidth = Math.min(_text.width, 400);

		_background = new FlxSprite(-4, -4).makeGraphic(Std.int(_text.fieldWidth + 8), Std.int(_text.height + 8), FlxColor.fromRGBFloat(0, 0, 0, 0.6));

		add(_background);
		add(_text);
	}

	override function update(elapsed:Float)
	{
		if (text != '' || text.length > 0)
		{
			_controlledAlpha += (elapsed * 1.175) * (targetAlpha > _controlledAlpha ? 1 : -1);
			_controlledAlpha = FlxMath.bound(_controlledAlpha, 0, 1);

			if (_background != null)
				_background.alpha = FlxEase.quadOut(_controlledAlpha);
			if (_text != null)
				_text.alpha = FlxEase.quadOut(_controlledAlpha);
		}

		super.update(elapsed);
	}

	function set_text(Text:String):String
	{
		_text.fieldWidth = 0;

		_text.text = Text;

		_text.fieldWidth = Math.min(_text.width, 400);

		_background.makeGraphic(Std.int(_text.fieldWidth + 8), Std.int(_text.height + 8), FlxColor.fromRGBFloat(0, 0, 0, 0.6));

		return Text;
	}
}
