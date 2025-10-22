package gear.input;

/**
 * Represents the runtime state of a single physical input (e.g., a specific key, mouse button).
 * It tracks its current state (active) and duration.
 */
class InputImpulse
{
    /**
     * The device type this impulse originates from (e.g., "keyboard", "mouse", "virtual").
     */
    public var device:String;

    /**
     * The specific code for this input (e.g., "A", "LMB", "GAMEPAD_A").
     */
    public var code:String;

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
     * TODO: Implement when Lime/OpenFL receives timestamp updates, or when we switch to a fork.
     * public var timestamp:Int64;*/

    public function new(device:String, code:String)
    {
        this.device = device;
        this.code = code;
        reset();
    }

    /**
     * Resets the impulse state, typically called when the input is not active.
     */
    public function reset():Void
    {
        active = false;
        duration = 0;
    }
}