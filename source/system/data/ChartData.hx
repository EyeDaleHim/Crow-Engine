package system.data;

typedef ChartData =
{
    @:optional var noteTypes:Array<String>;
    @:optional var notes:Array<Array<Float>>; // [0] = strum [1] = direction [2] = side [3] = type [4] = sustain

    @:optional var strumLength:Int;
    @:optional var playerControllers:Array<Int>;

    @:optional var overrideMeta:SongMetadata;

    @:optional var crowIdentifer:Int;
}