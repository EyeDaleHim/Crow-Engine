package states.editors;

class CharacterEditorGroup extends FlxContainer
{
    public var gameCamera:FlxCamera;
    public var hudCamera:FlxCamera;

    public var character:Character;

    override public function new()
    {
        super();

        gameCamera = new FlxCamera();
        FlxG.cameras.add(gameCamera, false);

        hudCamera = new FlxCamera();
        FlxG.cameras.add(hudCamera, false);

        
    }
}