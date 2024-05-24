package states.editors;

class StageEditorGroup extends FlxContainer
{
	override public function new()
	{
		super();

		add(new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF22BB0E));
	}
}
