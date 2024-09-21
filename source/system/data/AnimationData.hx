package system.data;

typedef AnimationData =
{
	var ?name:String;
	var ?prefix:String;
	var ?indices:Array<Int>;
	var ?fps:Float;
	var ?looped:Bool;
	var ?offset:IntPointData;
}
