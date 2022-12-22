package objects.character;

typedef CharacterData =
{
	var name:String; // character's name
	var healthColor:Int; // healthbar color
	var animationList:Array<Animation>; // list of animations, seriously
	var idleList:Array<String>; // if there's 2 of this, similar case to danceLEFT until danceRIGHT
	var missList:Array<String>; // misses, obviously
	var singList:Array<String>; // occasionally singLEFT, singDOWN and stuff
	var flip:{x:Bool, y:Bool};
	var scale:{x:Float, y:Float};
	@:optional var atlasType:String;
	// custom behavior stuff
	@:optional var behaviorType:String;
	// hair behavior
	@:optional var animationLoopPoint:Array<{animation:Animation, index:Int}>; // if the main animation finishes playing, where should it loop back?
}
