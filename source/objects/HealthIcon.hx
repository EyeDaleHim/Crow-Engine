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

	public override function new(x:Float = 0, y:Float = 0, char:String = 'bf')
	{
		super(x, y);

		// ill redo this in a later update, this isn't exactly >0.2.0 yet
		frames = Paths.getSparrowAtlas('characters/icons/sprite');

		for (anim in ['lose', 'neutral', 'win'])
		{
			addByPrefix(anim, '$char-$anim', 24, true);
		}

		updateHitbox();
		centerOffsets();

		antialiasing = Settings.getPref('antialiasing', true);

		changeState('neutral');
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
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
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
		if (existingName.contains(suffix))
			animation.play(suffix, true);
	}

	public var existingName:Array<String> = []; // i dont want any flixel errors ty

	private function addByPrefix(Name:String, Prefix:String, FrameRate:Int = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void
	{
		@:privateAccess
		{
			if (frames != null)
			{
				var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
				animation.findByPrefix(animFrames, Prefix); // adds valid frames to animFrames

				if (animFrames.length > 0)
				{
					var frameIndices:Array<Int> = new Array<Int>();
					animation.byPrefixHelper(frameIndices, animFrames, Prefix); // finds frames and appends them to the blank array

					if (frameIndices.length > 0)
					{
						var anim:FlxAnimation = new FlxAnimation(animation, Name, frameIndices, FrameRate, Looped, FlipX, FlipY);
						animation._animations.set(Name, anim);
					}

					existingName.push(Name);
				}
			}
		}
	}
}
