package mods;

typedef ModSong =
{
    var name:String;
    var color:Int;
    var icon:String;
    var difficulties:Array<String>; // if none, this defaults to parentWeek's difficulties, if it has one
    var defaultDifficulty:String;
    var parentWeek:String;
}