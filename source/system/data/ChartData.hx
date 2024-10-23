package system.data;

typedef ChartData =
{
    var ?noteTypes:Array<String>;
    var ?notes:Array<Array<Float>>; // [0] = strum [1] = direction [2] = side [3] = type [4] = sustain

    var ?events:Array<EventData>;

    var ?strumLength:Int;
    var ?strumList:SongStrumData;

    var ?overrideMeta:SongMetadata;

    var ?crowIdentifer:Int; // there are many different formats, only meant for converters to check for this field if it's OUR format
}