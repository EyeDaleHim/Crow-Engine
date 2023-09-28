package objects.notes;

import music.Song;
import objects.notes.Note;
import objects.notes.NoteFile;

@:allow(states.PlayState)
class NoteSplash extends FlxSprite
{
	private static var _splashFile:NoteSplashFile;
	private static var __pool:FlxTypedGroup<NoteSplash>;

	public var direction:Int = 0;

	private var animOffsets:Map<String, FlxPoint> = [];
	private var animFPS:Map<String, Int> = [];

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

			animFPS.set(animData.name, animData.fps);

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

		var animFramerate:Int = animFPS.exists(animName) ? animFPS.get(animName) : 24;

		animation.play(animName);
		if (animation?.curAnim != null)
			animation.curAnim.frameRate = animFramerate + FlxG.random.int(frameVariation.min, frameVariation.max);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(animName))
			offsetAnim.set(animOffsets[animName].x, animOffsets[animName].y);

		updateHitbox();
		offset.set(offsetAnim.x, offsetAnim.y);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (animation?.curAnim?.finished)
			kill();
	}
}
