package crow.ecs.entities;

/**
 * A way to interact with cameras like entities.
 * 
 * None of the fields here are representative of a sprite.
 * 
 * It only extends FlxSprite so that it can be added to an entity.
 */
class Camera extends FlxSprite
{
	public var cameraName:String;
	public var cameraReference:FlxCamera;

	public var scroll(get, set):FlxPoint;
    public var zoom(get, set):Float;

	public function new(name:String, ?x:Float = 0.0, ?y:Float = 0.0, ?width:Int = 0, ?height:Int = 0, ?zoom:Float = 0.0)
	{
		super();

		this.cameraName = name;
		this.cameraReference = new FlxCamera(x, y, width, height, zoom);
	}

    function get_scroll():FlxPoint
    {
        return this.cameraReference.scroll;
    }

    function set_scroll(value:FlxPoint):FlxPoint
    {
        return this.cameraReference.scroll = value;
    }  

    function get_zoom():Float
    {
        return this.cameraReference.zoom;
    }

    function set_zoom(value:Float):Float
    {
        return this.cameraReference.zoom = value;
    }

	override function get_width():Float
	{
		return this.cameraReference.width;
	}

	override function set_width(value:Float):Float
	{
		return this.cameraReference.width = Std.int(value);
	}

	override function get_height():Float
	{
		return this.cameraReference.height;
	}

	override function set_height(value:Float):Float
	{
		return this.cameraReference.height = Std.int(value);
	}

	override function set_x(value:Float):Float
	{
		this.cameraReference.x = value;
		return value;
	}

	override function set_y(value:Float):Float
	{
		this.cameraReference.y = value;
		return value;
	}
}
