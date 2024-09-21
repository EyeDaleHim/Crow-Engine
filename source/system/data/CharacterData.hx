package system.data;

typedef CharacterData =
{
	var ?name:String;
	var ?animations:Array<AnimationData>;

	var ?healthColor:FlxColor;

	var ?bopList:Array<String>;
	var ?missList:Array<String>;
	var ?singList:Array<String>;

	var ?iconName:String;

    var ?flip:AxePointData;
    var ?scale:FloatPointData;
}
