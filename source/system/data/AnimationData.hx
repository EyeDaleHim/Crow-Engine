package system.data;

typedef AnimationData =
{
	@:optional var name:String;
	@:optional var prefix:String;
	@:optional var indices:Array<Int>;
	@:optional var fps:Float;
	@:optional var looped:Bool;
	@:optional var offset:IntPointData;
}
