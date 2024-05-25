package system.data;

typedef WeekGlobalMetadata = {
    @:optional var name:String;
    @:optional var list:Array<String>;
}

typedef WeekMetadata = {
    @:optional var name:String;
    @:optional var description:String;
    @:optional var characters:Array<String>;
    @:optional var songList:Array<String>;
}