package objects.notes;

import music.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import backend.NoteStorageFunction;
import objects.notes.NoteFile;
import sys.FileSystem;
import openfl.Assets;
import haxe.Json;

using StringTools;

@:allow(states.PlayState)
class Note extends FlxSprite
{
	public var earlyMult:Float = 0.5;

	public static var currentSkin:String = 'NOTE_assets';

	public static var transformedWidth:Float = 160 * 0.7;

	public override function new(strumTime:Float = 0, direction:Int = 0, mustPress:Bool = false, sustainIndex:Float = 0, sustainLength:Float = 0,
			singAnim:String = '')
	{
		super();

		this.strumTime = strumTime;
		this.direction = direction;
		this.mustPress = mustPress;
		this.isSustainNote = sustainIndex > 0;
		this.singAnim = singAnim;

		if (_noteFile == null)
		{
			var path = Paths.imagePath('game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin').replace('png', 'json');

			if (!FileSystem.exists(path))
			{
				path = path.replace(currentSkin, 'NOTE_assets');
				FlxG.log.error('Couldn\'t find $currentSkin in "game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin"!');
			}

			_noteFile = Json.parse(Assets.getText(path));
		}

		if (_noteFile.scale == null)
			_noteFile.scale = {x: 0.7, y: 0.7};
		if (_noteFile.scaledArrow == null)
			_noteFile.scaledArrow = {x: 0, y: 0, type: "add"};
		if (_noteFile.scaledHold == null)
			_noteFile.scaledHold = {x: 0, y: 0, type: "add"};
		if (_noteFile.scaledEnd == null)
			_noteFile.scaledEnd = {x: 0, y: 0, type: "add"};

		frames = switch (_noteFile.atlasType)
		{
			case 'packer':
				Paths.getPackerAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin');
			default:
				Paths.getSparrowAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/$currentSkin');
		}

		for (animData in _noteFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, FlxPoint.get(animData.offset.x, animData.offset.y));
			animForces.set(animData.name, animData.looped);
		}

		var animPlay:String = _noteFile.animDirections[direction];

		if (isSustainNote)
		{
			flipY = Settings.getPref('downscroll', false);

			earlyMult = 1.0;

			if (sustainIndex > sustainLength)
			{
				animPlay = _noteFile.sustainAnimDirections[direction].end;
				isEndNote = true;
			}
			else
				animPlay = _noteFile.sustainAnimDirections[direction].body;
		}

		moves = false;

		animation.play(animPlay, true);
		scale.set(_noteFile.scale.x, _noteFile.scale.y);
		
		if (isSustainNote)
		{
			if (isEndNote)
				scale = modifyScale(scale, _noteFile.scaledEnd);
			else
				scale = modifyScale(scale, _noteFile.scaledHold);
		}
		else
			scale = modifyScale(scale, _noteFile.scaledArrow);
		updateHitbox();

		if (_noteFile.forcedAntialias != null)
			antialiasing = _noteFile.forcedAntialias;

		if (animation.curAnim.numFrames <= 1)
			animation.pause();
	}

	public var noteType:String = '';
	public var singAnim:String = '';
	public var missAnim:String = '';

	public var direction:Int = 0;
	public var strumTime:Float = 0;
	public var sustainLength:Float = 0;
	public var mustPress:Bool = false;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;

	private var _lastNote:Note;
	private var _hitSustain:Bool = false; // FOR GOD'S SAKE
	private var _lockedScaleY:Bool = true;
	private var _lockedToStrumX:Bool = true;
	private var _lockedToStrumY:Bool = true; // if you disable this, the notes won't ever go, if you want a modchart controlling notes, here u go

	private var animOffsets:Map<String, FlxPoint> = [];
	private var animForces:Map<String, Bool> = [];

	private static var _noteFile:NoteFile;

	// public var strumOwner:Int = 0; // enemy = 0, player = 1, useful if you wanna make a pasta night / bonedoggle gimmick thing
	public var canBeHit:Bool;
	public var tooLate:Bool;
	public var wasGoodHit:Bool;

	override public function update(elapsed:Float)
	{
		if (mustPress)
		{
			canBeHit = (strumTime > Conductor.songPosition - NoteStorageFunction.safeZoneOffset
				&& strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult));

			tooLate = (strumTime < Conductor.songPosition - NoteStorageFunction.safeZoneOffset && !wasGoodHit);
		}
		else
		{
			canBeHit = false;

			if (_lastNote != null)
			{
				wasGoodHit = ((strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult))
					&& ((isSustainNote && _lastNote.wasGoodHit) || strumTime <= Conductor.songPosition));
			}
		}

		super.update(elapsed);
	}

	private function modifyScale(point:FlxPoint, newPoint:{x:Float, y:Float, type:String}):FlxPoint
	{
		return switch (newPoint.type)
		{
			case 'multi':
				point.scale(newPoint.x, newPoint.y);
			default:
				point.add(newPoint.x, newPoint.y);
		};
	}

	function get__lastNote():Note
	{
		return _lastNote == null ? this : _lastNote;
	}
}
