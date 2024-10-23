package system.data;

typedef SongStrumData = {
    var ?controlledStrums:Array<Int>;
    var ?list:Array<StrumData>;
};

typedef StrumData = {
    var ?length:Int;
    var ?associatedChannel:String;
    var ?associatedSingers:Array<String>;
};