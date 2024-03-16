package states;

class PlayState extends MainState
{
    public static var instance:PlayState;

    // data
    public var chartFile:String = "";
    public var isStory:Bool = false;

    public var maxHealth:Float = 100.0;
    public var health:Float = 50.0;

    // cameras
    public var hudCamera:FlxCamera;

    // sprites
    // // hud
    public var infoText:FlxText;

    // // characters
    public var characterList:FlxTypedGroup<Character>;

    public var activeNotes:FlxTypedGroup<NoteSprite>;
    public var notes:Array<Note> = [];
    public var strumList:Array<FlxTypedGroup<StrumNote>>;

    public function new(chartFile:String = "", isStory:Bool = false)
    {
        super();

        this.chartFile = chartFile;
        this.isStory = isStory;

        MainState.conductor.position = 0.0;

        instance = this;
    }

    override function create()
    {
        hudCamera = new FlxCamera();
        FlxG.cameras.add(hudCamera, false);

        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

        FlxG.mouse.visible = false;

        super.create();
    }

    public function generateSong():Void
    {

    }
}