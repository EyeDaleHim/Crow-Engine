package objects;

// temporary file to easily create stages
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import.sys.FileSystem;
import objects.character.CharacterData.Animation;

class Stage
{
	public static function getStage(stage:String):FlxTypedGroup<FlxSprite>
	{
		var group:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

		switch (stage)
		{
			default:
				{
					var background:BGSprite = new BGSprite('stageback', {x: -600, y: -200}, {x: 0.9, y: 0.9});
					group.add(background);

					var front:BGSprite = new BGSprite('stagefront', {x: -650, y: 600}, {x: 0.9, y: 0.9});
					front.scale.set(1.1, 1.1);
					front.updateHitbox();
					group.add(front);

					var curtains:BGSprite = new BGSprite('stagecurtains', {x: -500, y: -300}, {x: 1.3, y: 1.3});
					curtains.scale.set(0.9, 0.9);
					curtains.updateHitbox();
					group.add(curtains);
				}
		}
		return group;
	}
}

class BGSprite extends FlxSprite
{
	public var graphicName:String = '';

	public function new(image:String, ?position:SimplePoint = {x: 0, y: 0}, ?scroll:SimplePoint = {x: 1.0, y: 1.0}, ?animArray:Array<Animation> = null)
	{
		super(position.x, position.y);
		scrollFactor.set(scroll.x, scroll.y);
		antialiasing = Settings.getPref('antialiasing', true);

		this.graphicName = image;

		if (animArray != null)
		{
			if (FileSystem.exists(Paths.image(image + '.xml')))
			{
				frames = Paths.getSparrowAtlas(image);

				for (anim in animArray)
				{
					animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);
				}
			}
			else
			{
				FlxG.log.error('The path ${Paths.image(image + '.xml')} doesn\'t exist!');
				this = null;
				return new BGSprite(image, position, scroll, null);
			}
		}
		else
		{
			loadGraphic(Paths.image(image));
		}
	}
}

typedef SimplePoint =
{
	var x:Float;
	var y:Float;
}
