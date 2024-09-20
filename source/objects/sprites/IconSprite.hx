package objects.sprites;

class IconSprite extends FlxSprite
{
    public static var iconSize:Int = 150;

    public var name:String = "";
    public var states:Array<String> = ["idle", "lose"];
    public var curState(default, set):String = "";

    function set_curState(value:String):String
    {
        this.curState = value;
        if (states.indexOf(value) != -1)
            animation.curAnim.curFrame = states.indexOf(value);
        else
            this.curState = states[0];

        return this.curState;
    }

    public function new(?x:Float = 0.0, ?y:Float = 0.0, ?iconName:String = "")
    {
        super(x, y);

        changeIcon(iconName);

        setGraphicSize(iconSize, iconSize);
        updateHitbox();
    }

    public function changeIcon(iconName:String):Void
    {
        this.name = iconName;

        var path:String = 'icons/$iconName';
        if (Assets.exists(path, Assets.imagePath))
        {
            var graph:FlxGraphic = Assets.image(path);

            loadGraphic(graph, true, graph.height, graph.height);
            animation.add(iconName, [0, 1], 0, false);
			animation.play(iconName);
        }
        else
        {
            changeIcon('face');
        }
    }
}