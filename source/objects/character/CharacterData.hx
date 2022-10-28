package objects.character;

typedef CharacterData =
{
	var name:String; // character's name
	var healthColor:Int; // healthbar color
	var animationList:Array<Animation>; // list of animations, seriously
	var idleList:Array<String>; // if there's 2 of this, similar case to danceLEFT until danceRIGHT
	var singList:Array<String>; // occasionally singLEFT, singDOWN and stuff
	var scale:{x:Float, y:Float};
}
