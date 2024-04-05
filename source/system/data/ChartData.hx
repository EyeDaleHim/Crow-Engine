package system.data;

typedef ChartData =
{
    @:optional var cachedNotes:Array<Array<Int>>;
    @:optional var noteTypes:Array<String>;
    @:optional var notes:Array<Array<Int>>; // [0] = definition [1] = index / [1] = strum [2] = direction [3] = side [4] = type [5] = sustain

    @:optional var playerNum:Int;
    @:optional var controlledStrums:Array<Int>;

    @:optional var overrideMeta:SongMetadata;
}