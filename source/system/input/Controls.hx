package system.input;

class Controls
{
    private static var heldKeys:Array<Int> = [];

    public static final justPressed:FlxTypedSignal<Int> = new FlxTypedSignal<Int>();
    public static final pressed:FlxTypedSignal<Int> = new FlxTypedSignal<Int>();

    public static final justReleased:FlxTypedSignal<Int> = new FlxTypedSignal<Int>();
    public static final released:FlxTypedSignal<Int> = new FlxTypedSignal<Int>();

    public static function init():Void
    {
        // FlxG.stage.addEventListener
    }
}