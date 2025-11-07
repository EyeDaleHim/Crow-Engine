package crow.input;

import flixel.input.keyboard.FlxKey;

/**
 * Represents the runtime state of a single physical input (e.g., a specific key, mouse button).
 * It tracks its current state (active) and duration.
 */
class InputImpulse
{
	/**
	 * The unique key for this impulse, combining device and code.
	 * Format: (deviceId << 24) | code
	 */
	public final impulseKey:Int;

	/**
	 * The device type this impulse originates from (e.g., "keyboard", "mouse").
	 */
	public var device(get, never):String;

	private function get_device():String
	{
		final deviceId = impulseKey >> 24;
		return switch (deviceId)
		{
			case 0: InputDevice.Keyboard;
			case 1: InputDevice.Mouse;
			default: "unknown";
		}
	}

	/**
	 * The specific string code for this input (e.g., "A", "LMB").
	 */
	public var code(get, never):String;

	private function get_code():String
	{
		final intCode = impulseKey & 0x00FFFFFF;
		final device = get_device();
		return switch (device)
		{
			case InputDevice.Keyboard:
				final keyStr = FlxKey.toStringMap.get(intCode);
				return (keyStr != null) ? keyStr : 'unknown_key:$intCode';
			case InputDevice.Mouse:
				final mouseStr = MouseButton.idToString(intCode);
				return (mouseStr != null) ? mouseStr : 'unknown_mouse:$intCode';
			default: 
                return 'unknown_code:$intCode';
		}
	}

	/**
	 * True while the input is currently held down.
	 */
	public var active:Bool;

	/**
	 * How long the input has been held down continuously, in seconds.
	 * Resets to 0 when the input is released.
	 */
	public var duration:Float;

	/**
	 * The timestamp when this impulse was last activated (pressed), in milliseconds.
	 * Useful for determining the order of key presses in combos.
	 * 
	 * Can break if the game is open for ~24 days straight, which is unrealistic.
	 * However, methods to get our timestamp only support Int32, so this is a compromise.
	 */
	public var timestamp:Int;

	public function new(impulseKey:Int)
	{
		this.impulseKey = impulseKey;
		reset();
	}

	/**
	 * Resets the impulse state, typically called when the input is not active.
	 */
	public function reset():Void
	{
		active = false;
		duration = 0;
		timestamp = -1;
	}

	public function toString():String
	{
		return 'InputImpulse[device=${device}, code=${code}, active=${active}, duration=${duration}, timestamp=${timestamp}]';
	}
}
