package objects;

// temporary file to easily create stages
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import sys.FileSystem;
import objects.character.CharacterData.Animation;

class Stage
{
	// don't really try to change this, this is just meant as a ref to the sprites
	public static var currentStage:String = '';

	public static function getStage(stage:String):Array<BGSprite>
	{
		var group:Array<BGSprite> = [];

		currentStage = stage;

		switch (stage)
		{
			default:
				{
					var background:BGSprite = new BGSprite({path: 'stageback', library: 'week1'}, {x: -600, y: -200}, {x: 0.9, y: 0.9});
					group.push(background);

					var front:BGSprite = new BGSprite({path: 'stagefront', library: 'week1'}, {x: -650, y: 600}, {x: 0.9, y: 0.9});
					front.scale.set(1.1, 1.1);
					front.updateHitbox();
					group.push(front);

					var curtains:BGSprite = new BGSprite({path: 'stagecurtains', library: 'week1'}, {x: -500, y: -300}, {x: 1.3, y: 1.3});
					curtains.scale.set(0.9, 0.9);
					curtains.updateHitbox();
					curtains.renderPriority = 0x01;
					group.push(curtains);
				}
		}

		currentStage = '';

		return group;
	}
}

class BGSprite extends FlxSprite
{
	public var graphicName:String = '';
	public var renderPriority:Int = 0x00; // this is literally just to tell you if this sprite wants to be rendered before or after the characters

	public function new(image:ImagePath, ?position:SimplePoint, ?scroll:SimplePoint, ?animArray:Array<Animation> = null)
	{
		if (position == null)
			position = {x: 0.0, y: 0.0};
		if (scroll == null)
			scroll = {x: 1.0, y: 1.0};

		super(position.x, position.y);
		scrollFactor.set(scroll.x, scroll.y);
		antialiasing = Settings.getPref('antialiasing', true);

		this.graphicName = image.library;

		image.path = Stage.currentStage + '/' + image.path;

		if (animArray != null)
		{
			// add null to those because we're telling it to look for it in the libraries
			if (FileSystem.exists(Paths.image(image.path + '.xml', image.library)))
			{
				frames = Paths.getSparrowAtlas(image.path, image.library);

				for (anim in animArray)
				{
					animation.addByPrefix(anim.name, anim.prefix, anim.fps, anim.looped);
				}
			}
			else
			{
				destroy();
			}
		}
		else
		{
			loadGraphic(Paths.image(image.path, image.library));
		}
	}
}

typedef ImagePath =
{
	var path:String;
	var library:Null<String>;
}

typedef SimplePoint =
{
	var x:Float;
	var y:Float;
}
