package backend.ui;

class List extends Box
{
    public static final defaultListStyle:Style = {
		width: 180,
		height: 360,
		bgColor: 0xFF212328,
		topLeftSize: 0.0,
		topRightSize: 0.0,
		botLeftSize: 0.0,
		botRightSize: 0.0,
		cornerSize: 0.0
	};

    public static final defaultListItemStyle:ItemStyle = {
        widthRatio: 0.95,
        heightRatio: 0.20,
        itemGap: 4.0
    };

    public var objects:Array<ItemData> = [];

    public var objectItems:Array<Button> = [];

    override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?itemStyle:ItemStyle)
    {
        super(x, y, ValidateUtils.validateListBoxStyle(style));


    }
}

class ListItem extends Button
{
    public var itemStyle:ItemStyle;

    override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?buttonStyle:ButtonStyle, ?itemStyle:ItemStyle, parent:List)
    {
        super(x, y, style, buttonStyle);

        itemStyle = ValidateUtils.validateListItemStyle(itemStyle);
    }
}

typedef ItemStyle = {
    @:optional var widthRatio:Float;
    @:optional var heightRatio:Float;
    @:optional var buttonStyle:ButtonStyle;
    @:optional var itemGap:Float;
};

@:structInit
typedef ItemData = {
    var display:String;
    @:optional var data:Dynamic;
};