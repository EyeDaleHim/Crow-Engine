package gear.objects.layout;

import gear.objects.layout.PsuedoRuling;

class UIComponent extends FlxSprite implements IFlxSprite
{
	// converts any object to a UIComponent
	public static function addAsComponent(object:FlxObject):UIComponent
	{
		var component = new UIComponent(object.x, object.y);
		object.x = 0;
		object.y = 0;
		component.add(object);
		component.setSize(object.width, object.height);
		component._isUIConverted = true;
		return component;
	}

	public var before:PsuedoRuling = new PsuedoRuling();
	public var after:PsuedoRuling = new PsuedoRuling();

	public var group(default, null):FlxTypedGroup<FlxObject>;
	public var members(get, never):Array<FlxObject>;

	private var _isUIConverted:Bool = false;

	public function new(x:Float = 0.0, y:Float = 0.0)
	{
		super(x, y);

		makeGraphic(1, 1, FlxColor.TRANSPARENT);
		group = new FlxTypedGroup<FlxObject>();
	}

	override public function update(elapsed:Float):Void
	{
		group.update(elapsed);
	}

	override public function draw():Void
	{
		// we don't need the overhead of drawing the sprite
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end

		group.draw();
	}

	override public function kill():Void
	{
		super.kill();
		group.kill();
	}

	override public function revive():Void
	{
		super.revive();
		group.revive();
	}

	override public function destroy():Void
	{
		super.destroy();
		group.destroy();
		group = null;
	}

	public function add(Object:FlxObject):FlxObject
	{
		return group.add(Object);
	}

	public function remove(Object:FlxObject):FlxObject
	{
		return group.remove(Object);
	}

	private function get_members():Array<FlxObject>
	{
		return group.members;
	}

	override function set_x(Value:Float):Float
	{
		if (_isUIConverted && members[0] != null)
		{
			members[0].x = Value;
		}

		return super.set_x(Value);
	}

	override function set_y(Value:Float):Float
	{
		if (_isUIConverted && members[0] != null)
		{
			members[0].y = Value;
		}

		return super.set_y(Value);
	}
}
