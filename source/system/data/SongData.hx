package system.data;

typedef SongMetadata =
{
    @:optional var player:String;
    @:optional var opponent:String;
    @:optional var spectator:String;

    @:optional var bpm:Float;
    @:optional var speed:Float;
    @:optional var stage:String;

    @:optional var difficulty:Int;

    @:optional var channels:Array<String>;
}

typedef SongDisplayData = {
    @:optional var name:String;
    @:optional var color:Int;
    @:optional var char:String;
}