package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import objects.notes.NoteFile;
import sys.FileSystem;
import openfl.Assets;
import haxe.Json;

using StringTools;

class StrumNote extends FlxSprite
{
	public static var currentSkin:String = 'NOTE_assets';

	public var direction:Int = 0;
	public var confirmAnim:String = '';
	public var pressAnim:String = '';
	public var staticAnim:String = '';

	private var animOffsets:Map<String, FlxPoint> = [];
	private var animForces:Map<String, Bool> = [];
	private var _strumFile:NoteFile.StrumNoteFile;

	public override function new(direction:Int = 0)
	{
		super();

		this.direction = direction;

		var path:String = Paths.image('game/ui/STRUM_$currentSkin').replace('png', 'json');

		if (!FileSystem.exists(path))
		{
			path = path.replace(currentSkin, 'NOTE_assets');
			FlxG.log.error('Couldn\'t find $currentSkin in "game/ui/$currentSkin"!');
		}

		_strumFile = Json.parse(Assets.getText(path));

		frames = Paths.getSparrowAtlas('game/ui/$currentSkin');

		for (animData in _strumFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, new FlxPoint(animData.offset.x, animData.offset.y));
			animForces.set(animData.name, animData.looped);
		}

		confirmAnim = _strumFile.confirmAnim[direction];
		pressAnim = _strumFile.pressAnim[direction];
		staticAnim = _strumFile.staticAnim[direction];

		animation.play(staticAnim);

		scale.set(0.7, 0.7);
		updateHitbox();
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
