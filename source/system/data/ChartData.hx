package system.data;

typedef ChartData =
{
    @:optional var noteTypes:Array<String>;
    @:optional var notes:Array<Dynamic>; // [0] = strum [1] = direction [2] = side [3] = type
}