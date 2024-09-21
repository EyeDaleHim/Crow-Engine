package system.data;

typedef SongMetadata =
{
    var ?characters:SongCharacterListData;

    var ?bpm:Float;
    var ?speed:Float;
    var ?stage:String;

    var ?difficulty:Int;

    var ?channels:Array<String>;

    var ?songDisplay:SongDisplayData;
}

typedef SongCharacterListData = {
    var ?players:Array<String>;
    var ?opponents:Array<String>;
    var ?spectators:Array<String>;
}

typedef SongDisplayData = {
    var ?name:String;
    var ?color:Int;
    var ?char:String;
}