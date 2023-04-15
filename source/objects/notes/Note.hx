package objects.notes;

import music.Song;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxPool;
import backend.NoteStorageFunction;
import objects.notes.NoteFile;
import openfl.Assets;
import haxe.Json;

using StringTools;

@:allow(states.PlayState)
@:allow(states.debug.game.ChartEditorState)
@:allow(objects.notes.NoteSprite)
@:allow(objects.notes.SustainNote)
class Note
{
	public var earlyMult:Float = 0.5;

	public static var currentSkin:String = 'NOTE_assets';

	public static var transformedWidth:Float = 160 * 0.7;

	public var noteSprite:NoteSprite;

	public function new(strumTime:Float = 0, direction:Int = 0, mustPress:Bool = false, sustainIndex:Float = 0, sustainLength:Float = 0, singAnim:String = '')
	{
		this.strumTime = strumTime;
		this.direction = direction;
		this.mustPress = mustPress;
		this.sustainIndex = sustainIndex;
		this.isSustainNote = sustainIndex > 0;
		this.singAnim = singAnim;

		if (!isSustainNote)
			earlyMult = 1.0;

		if (Note._noteFile == null)
		{
			var path = Paths.imagePath('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}').replace('png', 'json');

			if (!Tools.fileExists(path))
			{
				path = path.replace(Note.currentSkin, 'NOTE_assets');
				FlxG.log.error('Couldn\'t find ${Note.currentSkin} in "game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}"!');
			}

			Note._noteFile = Json.parse(Assets.getText(path));
		}
	}

	public var noteType:String = '';
	public var singAnim:String = '';
	public var missAnim:String = '';

	public var direction:Int = 0;
	public var strumTime:Float = 0;
	public var sustainIndex:Float = 0;
	public var sustainLength:Float = 0;
	public var mustPress:Bool = false;

	private var _lastNote:Note;
	private var _hitSustain:Bool = false; // FOR GOD'S SAKE

	private static var _noteFile:NoteFile;

	public var noteChildrens:Array<Note> = [];
	public var parentNote:Note;
	public var isSustainNote:Bool = false;
	public var isEndNote:Bool = false;

	// public var strumOwner:Int = 0; // enemy = 0, player = 1, useful if you wanna make a pasta night / bonedoggle gimmick thing
	public var canBeHit:Bool;
	public var tooLate:Bool;
	public var wasGoodHit:Bool;

	function get__lastNote():Note
	{
		return _lastNote == null ? this : _lastNote;
	}
}

// will change this soon in favor of a new note rendering process
// for now, repurpose this class so i can do a pool thing

@:allow(states.PlayState)
class NoteSprite extends FlxSprite
{
	public static var __pool:FlxPool<NoteSprite>;

	public var note:Note;

	override public function new(?note:Note = null)
	{
		super();

		scrollFactor.set();

		this.note = note;

		if (note != null)
			note.noteSprite = this;

		frames = switch (Note._noteFile.atlasType)
		{
			case 'packer':
				Paths.getPackerAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
			default:
				Paths.getSparrowAtlas('game/ui/noteSkins/${Song.metaData.noteSkin}/${Note.currentSkin}');
		}

		for (animData in Note._noteFile.animationData)
		{
			if (animData.indices != null && animData.indices.length > 0)
				animation.addByIndices(animData.name, animData.prefix, animData.indices, "", animData.fps, animData.looped);
			else
				animation.addByPrefix(animData.name, animData.prefix, animData.fps, animData.looped);

			if (animData.offset.x != 0 || animData.offset.y != 0)
				animOffsets.set(animData.name, FlxPoint.get(animData.offset.x, animData.offset.y));
			animForces.set(animData.name, animData.looped);
		}

		if (Note._noteFile.scale == null)
			Note._noteFile.scale = {x: 0.7, y: 0.7};
		if (Note._noteFile.scaledArrow == null)
			Note._noteFile.scaledArrow = {x: 0, y: 0, type: "add"};
		if (Note._noteFile.scaledHold == null)
			Note._noteFile.scaledHold = {x: 0, y: 0, type: "add"};
		if (Note._noteFile.scaledEnd == null)
			Note._noteFile.scaledEnd = {x: 0, y: 0, type: "add"};

		refreshNote(note);

		moves = false;
	}

	public function refreshNote(note:Note)
	{
		var animPlay:String = '';

		if (note != null)
		{
			animPlay = Note._noteFile.animDirections[note == null ? 0 : note.direction];

			this.note = note;
			this.note.noteSprite = this;

			if (note.isSustainNote)
			{
				alpha = 0.6;
				flipY = Settings.getPref('downscroll', false);

				if (note.sustainIndex > note.sustainLength)
				{
					animPlay = Note._noteFile.sustainAnimDirections[note.direction].end;
					note.isEndNote = true;
				}
				else
					animPlay = Note._noteFile.sustainAnimDirections[note.direction].body;
			}
		}

		if (animPlay != '')
			animation.play(animPlay, true);
		scale.set(Note._noteFile.scale.x, Note._noteFile.scale.y);

		if (note != null)
		{
			if (note.isSustainNote)
			{
				if (note.isEndNote)
					scale = modifyScale(scale, Note._noteFile.scaledEnd);
				else
					scale = modifyScale(scale, Note._noteFile.scaledHold);
			}
			else
				scale = modifyScale(scale, Note._noteFile.scaledArrow);
		}
		updateHitbox();

		if (Note._noteFile.forcedAntialias != null)
			antialiasing = Note._noteFile.forcedAntialias;

		if (animation != null)
		{
			if (animation.curAnim != null)
			{
				if (animation.curAnim.numFrames <= 1)
					animation.pause();
			}
		}
	}

	private var animOffsets:Map<String, FlxPoint> = [];
	private var animForces:Map<String, Bool> = [];

	private var _lockedScaleY:Bool = true;
	private var _lockedToStrumX:Bool = true;
	private var _lockedToStrumY:Bool = true; // if you disable this, the notes won't ever go, if you want a modchart controlling notes, here u go

	override public function update(elapsed:Float)
	{
		if (note != null)
		{
			if (note.mustPress)
			{
				note.canBeHit = (note.strumTime > Conductor.songPosition - NoteStorageFunction.safeZoneOffset
					&& note.strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * note.earlyMult));

				if (!note.tooLate)
					note.tooLate = (note.strumTime < Conductor.songPosition - NoteStorageFunction.safeZoneOffset && !note.wasGoodHit);
				else
					alpha = 0.3;
			}
			else
			{
				note.canBeHit = false;

				if (note._lastNote != null)
				{
					note.wasGoodHit = ((note.strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * note.earlyMult))
						&& ((note.isSustainNote && note._lastNote.wasGoodHit) || note.strumTime <= Conductor.songPosition));
				}
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

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}

}

/*class SustainNote extends NoteSprite
{
	public static var __pool:FlxPool<SustainNote>;

	override public function new(?note:Note = null)
	{
		super(note);
	}

	override public function draw():Void
	{
		super.draw();

		if (note == null)
		{
			for (i in 0...Std.int(note.sustainLength))
			{

			}
		}
	}
}*/
