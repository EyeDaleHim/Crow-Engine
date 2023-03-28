package mods;

import weeks.LevelHandler.WeekStructure;

typedef ModWeek =
{
    > WeekStructure,
    @:optional var modParent:String;
}