package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import music.Song;

class NoteSplash extends FlxSprite
{
	public function new(x:Float, y:Float, direction:Int = 0)
	{
		super(x, y);

        frames = Paths.getSparrowAtlas('game/ui/splashSkins/${Song.metaData.noteSkin}/noteSplashes');

        animation.addByPrefix('splash-0-1', 'note impact 1 purple', 24, false);
        animation.addByPrefix('splash-0-2', 'note impact 2 purple', 24, false);
        animation.addByPrefix('splash-1-1', 'note impact 1 blue', 24, false);
        animation.addByPrefix('splash-1-2', 'note impact 2 blue', 24, false);
        animation.addByPrefix('splash-2-1', 'note impact 1 green', 24, false);
        animation.addByPrefix('splash-2-2', 'note impact 2 green', 24, false);
        animation.addByPrefix('splash-3-1', 'note impact 1 red', 24, false);
        animation.addByPrefix('splash-3-2', 'note impact 2 red', 24, false);

        animation.play('splash-' + direction + '-' + FlxG.random.int(1, 2));
        animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        updateHitbox();

        offset.set(width * 0.3, height * 0.3);

        alpha = 0.6;
	}

    override public function update(elapsed:Float)
    {
        if (animation.curAnim.finished)
            kill();

        super.update(elapsed);
    }
}
