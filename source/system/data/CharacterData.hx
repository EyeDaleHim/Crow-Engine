package system.data;

typedef CharacterData =
{
	@:optional var name:String;
	@:optional var animations:Array<AnimationData>;

	@:optional var healthColor:FlxColor;

	@:optional var bopList:Array<String>;
	@:optional var missList:Array<String>;
	@:optional var singList:Array<String>;

	@:optional var iconName:String;

    @:optional var flip:AxePointData;
    @:optional var scale:FloatPointData;
}
