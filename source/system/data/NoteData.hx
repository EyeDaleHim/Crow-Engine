package system.data;

typedef NoteData = {
    @:optional var strumTime:Float;
    @:optional var direction:Int;
    @:optional var side:Int; // 0 or 1
    @:optional var type:Int;
    @:optional var sustain:Float;
};