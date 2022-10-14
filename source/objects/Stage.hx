package objects;

// temporary file to easily create stages
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;

class Stage
{
	public static function getStage(stage:String):FlxTypedGroup<FlxSprite>
	{
		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

		switch (stage)
		{
			case 'stage':
				{
					// var stage:
				}
		}
		return group;
	}
}
