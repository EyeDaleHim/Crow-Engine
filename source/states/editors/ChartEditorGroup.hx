package states.editors;

class ChartEditorGroup extends FlxContainer
{
    public var gameCamera:FlxCamera;
    public var hudCamera:FlxCamera;

    override public function new()
    {
        super();

        gameCamera = new FlxCamera();
        FlxG.cameras.add(gameCamera, false);

        hudCamera = new FlxCamera();
        FlxG.cameras.add(hudCamera, false);
    }
}
