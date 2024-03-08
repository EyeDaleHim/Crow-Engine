package system.data;

typedef ChartData =
{
    @:optional var chartFileName:String;

    @:optional var noteTypes:Array<String>;
    @:optional var notes:Array<Int>;
}