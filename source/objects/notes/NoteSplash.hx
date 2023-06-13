package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxPool;
import music.Song;
import objects.notes.Note;
import objects.notes.NoteFile;
import openfl.Assets;
import tjson.TJSON as Json;

@:allow(states.PlayState)
class NoteSplash extends FlxSprite
{
	private static var _splashFile:NoteSplashFile;
    private static var __pool:FlxPool<NoteSplash>;

	public var direction:Int = 0;

    private var animOffsets:Map<String, FlxPoint> = [];

	public function new(?x:Float = 0, ?y:Float = 0)
	{
		if (NoteSplash._splashFile == null)
		{
			var path = Paths.imagePath('game/ui/splashSkins/${Song.metaData.noteSkin}/noteSplashes').replace('png', 'json');

			if (!Tools.fileExists(path))
			{
				path = path.replace(Note.currentSkin, 'NOTE_assets');
				FlxG.log.error('Couldn\'t find ${Note.currentSkin} in "game/ui/splashSkins/${Song.metaData.noteSkin}/noteSplashes"!');
			}

			NoteSplash._splashFile = Json.parse(Assets.getText(path));
		}

		super(x, y);

		frames = Paths.getSparrowAtlas('game/ui/splashSkins/${Song.metaData.noteSkin}/noteSplashes');

		for (animData in NoteSplash._splashFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, FlxPoint.get(animData.offset.x, animData.offset.y));
        }

		alpha = 0.6;

        exists = false;
        moves = false;
	}

	public function playSplash(?x:Float = 0, ?y:Float = 0, ?direction:Int = 0):Void
	{
        setPosition(x, y);
        this.direction = direction;

		var frameVariation = _splashFile.frameRateVariation ?? {min: 0, max: 0};
        var animName:String = FlxG.random.getObject(_splashFile.directionNames[direction]); 

		animation.play(animName);
        if (animation?.curAnim != null)
		    animation.curAnim.frameRate += FlxG.random.int(frameVariation.min, frameVariation.max);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(animName))
			offsetAnim.set(animOffsets[animName].x, animOffsets[animName].y);

        updateHitbox();
        offset.set(offsetAnim.x, offsetAnim.y);

        trace(offset);
	}

	override public function update(elapsed:Float)
	{
        if (animation?.curAnim?.finished)
			kill();

		super.update(elapsed);
	}
}
