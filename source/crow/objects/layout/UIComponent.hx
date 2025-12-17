package crow.objects.layout;

import crow.ecs.components.ModelComponent;
import crow.objects.layout.PsuedoRuling;

class UIComponent extends FlxSprite implements IFlxSprite
{
	// converts any object to a UIComponent
	public static function addAsComponent(object:Entity):UIComponent
	{
		final model = object.getModel();
		if (model == null)
			return null;

		var component = new UIComponent(model.x, model.y);
		model.x = 0;
		model.y = 0;
		component.add(model);
		component.setSize(model.width, model.height);
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

	public function add<T:FlxObject>(Object:T):T
	{
		group.add(Object);
		return Object;
	}

	public function remove<T:FlxObject>(Object:T):T
	{
		group.remove(Object);
		return Object;
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
