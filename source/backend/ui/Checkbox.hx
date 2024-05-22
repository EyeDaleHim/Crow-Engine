package backend.ui;

class Checkbox extends FlxSprite
{
    public var checkOverlap:Void->FlxPoint;
    
    public var onHover:Void->Void;
    public var onClick:Void->Void;

    public var checked:Bool = false;

    public var checkColor:FlxColor = 0xFFFFFFFF;

    public var activeGraph:FlxGraphic;
    public var inactiveGraph:FlxGraphic;

    override public function new(?x:Float = 0.0, ?y:Float = 0.0, ?width:Int = 20, ?height:Int = 20, ?checkColor:FlxColor =0xFFFFFFFF, checkValue:Bool = false)
    {
        super(x, y);

        checked = checkValue;

        width = Math.max(20, width).floor();
        height = Math.max(20, height).floor();

        var sharedKey:String = '${width}_${height}_checkbox_${checkColor.toHexString(false, false)}';

        activeGraph = FlxGraphic.fromBitmapData(new BitmapData(width, height, true, FlxColor.WHITE), sharedKey + '_active');
        inactiveGraph = FlxGraphic.fromBitmapData(new BitmapData(width, height, true, FlxColor.WHITE), sharedKey + '_inactive');

        inactiveGraph.bitmap.lock();
        inactiveGraph.bitmap.fillRect(new Rectangle(4, 4, width - 8, height - 8), FlxColor.TRANSPARENT);
        inactiveGraph.bitmap.unlock();

        activeGraph.bitmap.lock();
        activeGraph.bitmap.fillRect(new Rectangle(4, 4, width - 8, height - 8), FlxColor.TRANSPARENT);
        activeGraph.bitmap.fillRect(new Rectangle(6, 6, width - 12, height - 12), FlxColor.WHITE);
        activeGraph.bitmap.unlock();

        if (checkValue)
            loadGraphic(activeGraph);
        else
            loadGraphic(inactiveGraph);

        color = checkColor;
    }

    override public function update(elapsed:Float)
    {
        

        super.update(elapsed);
    }
}