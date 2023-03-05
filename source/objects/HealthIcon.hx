package objects;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

using StringTools;

// todo: allow animated icons :O
class HealthIcon extends FlxSprite
{
	public var char:String;
	public var sprTracker:FlxSprite;
	public var offsetTracker(default, null):FlxPoint = FlxPoint.get();

	public override function new(x:Float = 0, y:Float = 0, char:String = 'bf')
	{
		super(x, y);

		// ill redo this in a later update, this isn't exactly >0.2.0 yet
		frames = Paths.getSparrowAtlas('characters/icons/sprite');

		char = char.replace('-holding-gf', ''); // we need a better way to do this

		char = char.replace('-car', '');
		char = char.replace('-christmas', '');
		char = char.replace('-tankmen', '');

		for (anim in ['lose', 'neutral', 'win'])
		{
			animation.addByPrefix(anim, '$char-$anim', 24, true);
		}

		antialiasing = Settings.getPref('antialiasing', true);

		changeState('neutral');

		moves = false;

		updateHitbox();
		centerOffsets();
	}

	public var updateScale:Bool = false;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (updateScale)
		{
			scale.x = Tools.lerpBound(scale.x, 1, elapsed * 9);
			scale.y = Tools.lerpBound(scale.y, 1, elapsed * 9);

			updateHitbox();
			centerOffsets();

			if (sprTracker != null)
			{
				offset.x = FlxMath.remapToRange(scale.x, 1, 1.2, 0, 15);
				if (flipX)
					offset.x *= -1;
			}
		}

		if (sprTracker != null)
			setPosition(sprTracker.x + offsetTracker.x, sprTracker.y + offsetTracker.y);
	}

	// need sprTracker if you wanna make 'em beat, otherwise, just scales by itself.
	public function beatHit()
	{
		scale.set(1.2, 1.2);

		if (sprTracker != null)
		{
			offset.x = FlxMath.remapToRange(scale.x, 1, 1.2, 0, 15);
			if (flipX)
				offset.x *= -1;
		}
	}

	public function changeState(suffix:String)
	{
		if (animation.getByName(suffix) != null)
			animation.play(suffix, true);
	}
}
