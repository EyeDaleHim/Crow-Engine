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

	public var scroll:Int = 0;

	public var onItemSelect:Dynamic->Void;

	public var objectItems:Array<ListItem> = [];

	private var itemList:Array<ItemData> = [];

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
				cornerSize: 8.0,
				bgColor: 0xFF000000
			}, {
				hoverColor: 0xFF141618,
				clickColor: 0xFF303336,
				autoSize: null,
				alignment: LEFT
			}, itemStyle, this);
			item.ID = objectItems.length;
			item.onClick = function()
			{
				if (onItemSelect != null)
					onItemSelect(itemList[item.ID]);
			};
			item.centerOverlay(this, X);

			objectItems.push(item);

			item.kill();

			size += (height * itemStyle.heightRatio) + itemStyle.itemGap;
		}

		for (i in 0...30)
		{
			add('mything$i');
		}
	}

	public function add(item:OneOfTwo<String, ItemData>)
	{
		if (item != null)
		{
			if (Std.isOfType(item, String))
				itemList.push({display: cast(item, String)});
			else
				itemList.push(item);

			if (itemList.length <= objectItems.length)
			{
				objectItems[itemList.length - 1].textDisplay.text = itemList[itemList.length - 1].display;
				objectItems[itemList.length - 1].revive();
			}
		}
	}

	override public function update(elapsed:Float)
	{
		if (!exists && !active)
			return;

		super.update(elapsed);

		if (FlxG.mouse.overlaps(this) && FlxG.mouse.wheel != 0)
		{
			var lastScroll:Int = scroll;

			scroll = FlxMath.bound(scroll - FlxG.mouse.wheel, 0, Math.max(0, itemList.length - objectItems.length)).floor();

			if (lastScroll != scroll)
			{
				for (i in 0...objectItems.length)
				{
					objectItems[i].textDisplay.text = itemList[scroll + i].display;
				}
			}
		}

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
