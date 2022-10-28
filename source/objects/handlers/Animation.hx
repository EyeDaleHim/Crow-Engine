package objects.handlers;

typedef Animation =
{
	var name:String;
	var prefix:String;
	var indices:Array<Int>;
	var fps:Int;
	var looped:Bool;
	var forced:Bool;
	var offset:{x:Int, y:Int};
}
