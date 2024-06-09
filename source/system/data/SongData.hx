package system.data;

typedef SongMetadata =
{
    @:optional var characters:SongCharacterListData;

    @:optional var bpm:Float;
    @:optional var speed:Float;
    @:optional var stage:String;

    @:optional var difficulty:Int;

    @:optional var channels:Array<String>;

    @:optional var songDisplay:SongDisplayData;
}

typedef SongCharacterListData = {
    @:optional var players:Array<String>;
    @:optional var opponents:Array<String>;
    @:optional var spectators:Array<String>;
}

typedef SongDisplayData = {
    @:optional var name:String;
    @:optional var color:Int;
    @:optional var char:String;
}