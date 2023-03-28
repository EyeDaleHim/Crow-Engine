package mods;

import weeks.LevelHandler.SongStructure;

typedef ModSong =
{
    > SongStructure,
    @:optional var modParent:String;
}