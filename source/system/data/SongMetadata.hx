package system.data;

typedef SongMetadata =
{
    @:optional var player:String;
    @:optional var opponent:String;
    @:optional var spectator:String;

    @:optional var bpm:Float;
    @:optional var speed:Float;
    @:optional var stage:String;
}