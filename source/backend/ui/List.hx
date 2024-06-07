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
		heightRatio: 0.09,
		itemGap: 6.0
	};

	public var objectItems:Array<ListItem> = [];

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?itemStyle:ItemStyle)
	{
		style = ValidateUtils.validateListBoxStyle(style);
		itemStyle = ValidateUtils.validateListItemStyle(itemStyle);

		super(x, y, style);

		var size:Float = itemStyle.itemGap;
		while (size + (height * itemStyle.heightRatio) < height)
		{
			var item:ListItem = new ListItem(x + itemStyle.itemGap, y + size, {
				width: (style.width * itemStyle.widthRatio).floor(),
				height: (style.height * itemStyle.heightRatio).floor(),
				cornerSize: 8.0
			}, {autoSize: null, alignment: LEFT}, this);
			objectItems.push(item);
			item.centerOverlay(this, X);

			size += (height * itemStyle.heightRatio) + itemStyle.itemGap;
		}
	}

	override public function update(elapsed:Float)
	{
		if (!exists && !active)
			return;

		super.update(elapsed);
		for (member in objectItems)
		{
			if (member.exists && member.active)
				member.update(elapsed);
		}
	}

	override public function draw()
	{
		if (!exists && !visible)
			return;

		super.draw();
		for (member in objectItems)
		{
			if (member.exists && member.visible)
				member.draw();
		}
	}
}

class ListItem extends Button
{
	public var itemStyle:ItemStyle;

	override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?style:Style, ?buttonStyle:ButtonStyle, ?itemStyle:ItemStyle, parent:List)
	{
		itemStyle = ValidateUtils.validateListItemStyle(itemStyle);

		super(x, y, style, buttonStyle);
	}
}

typedef ItemStyle =
{
	@:optional var widthRatio:Float;
	@:optional var heightRatio:Float;
	@:optional var buttonStyle:ButtonStyle;
	@:optional var itemGap:Float;
};

@:structInit
typedef ItemData =
{
	var display:String;
	@:optional var data:Dynamic;
};
