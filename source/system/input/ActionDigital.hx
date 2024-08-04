package system.input;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxAction.FlxActionDigital;

class ActionDigital extends FlxActionDigital
{
	public var controlOrigin:Control;

	public var persist:Bool = false;
	public var savedState:Null<FlxInputState> = null;

	public var active:Bool = true;

	override public function check():Bool
	{
		if (!active)
			return false;
		return super.check();
	}
}
