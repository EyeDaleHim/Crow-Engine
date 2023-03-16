package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import objects.notes.NoteFile;
import music.Song;
import openfl.Assets;
import haxe.Json;

using StringTools;

@:allow(states.PlayState)
class StrumNote extends FlxSprite
{
	public static var currentSkin:String = 'NOTE_assets';

	public var direction:Int = 0;
	public var confirmAnim:String = '';
	public var pressAnim:String = '';
	public var staticAnim:String = '';

	public var downScroll:Bool = false;

	private var animOffsets:Map<String, FlxPoint> = [];

	private static var _strumFile:NoteFile.StrumNoteFile;

	public override function new(direction:Int = 0)
	{
		super();

		downScroll = Settings.getPref("downscroll", false);

		this.direction = direction;

		var path:String = Paths.imagePath('game/ui/noteSkins/${Song.metaData.noteSkin}/STRUM_$currentSkin').replace('png', 'json');

		if (!Tools.fileExists(path))
		{
			path = path.replace(currentSkin, 'NOTE_assets');
			FlxG.log.error('Couldn\'t find $currentSkin in "game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin"!');
		}

		if (_strumFile == null)
			_strumFile = Json.parse(Assets.getText(path));

		if (_strumFile.scale == null)
			_strumFile.scale = {x: 0.7, y: 0.7};

		frames = switch (_strumFile.atlasType)
		{
			case 'packer':
				Paths.getPackerAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin');
			default: 
				Paths.getSparrowAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin');
		}

		for (animData in _strumFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, FlxPoint.get(animData.offset.x, animData.offset.y));
		}

		confirmAnim = _strumFile.confirmAnim[direction];
		pressAnim = _strumFile.pressAnim[direction];
		staticAnim = _strumFile.staticAnim[direction];

		moves = false;

		playAnim(staticAnim);

		scale.set(_strumFile.scale.x, _strumFile.scale.y);
		updateHitbox();

		if (_strumFile.forcedAntialias != null)
			antialiasing = _strumFile.forcedAntialias;
	}

	public var animationTime:Float = 0.0;

	override function update(elapsed:Float)
	{
		if (animation.curAnim != null)
		{
			if (animationTime <= 0.0)
			{
				if (animation.curAnim.name != pressAnim)
				{
					playAnim(staticAnim);
					animationTime = 0.0;
				}
			}
			else
			{
				animationTime -= elapsed;
			}
		}

		super.update(elapsed);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var offsetAnim:FlxPoint = FlxPoint.get();
		if (animOffsets.exists(AnimName))
			offsetAnim.set(animOffsets[AnimName].x, animOffsets[AnimName].y);
		else
			centerOffsets();
		centerOrigin();
	}
}
