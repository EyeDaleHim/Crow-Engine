package system.data;

typedef ChartData =
{
    var ?noteTypes:Array<String>;
    var ?notes:Array<Array<Float>>; // [0] = strum [1] = direction [2] = side [3] = type [4] = sustain

    var ?strumLength:Int;
    var ?playerControllers:Array<Int>;

    var ?overrideMeta:SongMetadata;

    var ?crowIdentifer:Int;
}