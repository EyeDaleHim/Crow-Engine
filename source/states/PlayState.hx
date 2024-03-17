package states;

import backend.game.Chart;

class PlayState extends MainState
{
    public static var instance:PlayState;

    // data
    public var isStory:Bool = false;

    public var chartFile:String = "";
    public var chartData:ChartData = DataManager.emptyChart;
    public var songMeta:SongMetadata;

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
    public var strumList:Array<FlxTypedGroup<StrumNote>> = [];

    public var controlledStrums:Array<FlxTypedGroup<StrumNote>> = [];

    public function new(chartFile:String = "", isStory:Bool = false)
    {
        super();

        this.chartFile = chartFile;
        this.isStory = isStory;

        MainState.conductor.position = 0.0;
        MainState.conductor.active = false;

        if (FileSystem.exists(Assets.assetPath('data/songs/$chartFile.json')))
            DataManager.loadedCharts.set(chartFile, Json.parse(Assets.assetPath('data/songs/$chartFile.json')));
        else
            chartData = DataManager.emptyChart;

        instance = this;
    }

    override function create()
    {
        hudCamera = new FlxCamera();
        FlxG.cameras.add(hudCamera, false);

        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

        FlxG.mouse.visible = false;

        generateSong();

        activeNotes = new FlxTypedGroup<NoteSprite>();

        for (i in 0...(chartData.playerNum ?? 2))
        {
            generateStrum(FlxG.width / 2);
        }

        var controlledPlayers:Array<Int> = chartData.controlledStrums ?? [1];
        for (i in 0...controlledPlayers.length)
        {
            if (strumList[controlledPlayers[i]] != null)
                controlledStrums.push(strumList[controlledPlayers[i]]);
        }

        super.create();
    }

    public function generateStrum(gap:Float):Void
    {
        var strumGroup:FlxTypedGroup<StrumNote> = new FlxTypedGroup<StrumNote>();
        strumGroup.camera = hudCamera;

        var startX:Float = 75;
        var startY:Float = 20;

        for (i in 0...4)
        {
            var strumNote:StrumNote = new StrumNote(i);
            strumNote.ID = i;

            strumNote.x = startX + (strumList.length == 0 ? 25 : 0) + (Note.noteWidth * i) + (gap * strumList.length);
            strumNote.y = startY;

            strumGroup.add(strumNote);
        }

        add(strumGroup);

        strumList.push(strumGroup);
    }

    public function generateSong():Void
    {
        notes = Chart.read(chartData);
    }

    override public function update(elapsed:Float)
    {
        if (notes.length > 0)
        {
            var spawnTime:Float = 3000 / songMeta.speed;

            var i:Int = notes.length;

            while (i >= 0)
            {
                if (notes[i].strumTime - (MainState.conductor.position - MainState.conductor.offset) <= spawnTime)
                {
                    var noteSpr:NoteSprite = activeNotes.recycle(NoteSprite);
                    noteSpr.noteData = notes[i];

                    activeNotes.add(noteSpr);
                }
                else
                {
                    notes.splice(i, notes.length);
                    break;
                }
                i--;
            }
        }

        super.update(elapsed);
    }
}