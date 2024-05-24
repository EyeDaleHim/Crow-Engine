package states.editors;

class ChartEditorGroup extends FlxContainer
{
	override public function new()
	{
		super();

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF0E59BB));
	}
}
