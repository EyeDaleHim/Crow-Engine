package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import haxe.ds.List;
import objects.notes.Note;
import objects.notes.StrumNote;

class PlayState extends MusicBeatState
{
	// Camera Stuff
	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var otherCameras:Map<String, FlxCamera> = new Map();

	public var camFollowObject:FlxObject;
	public var camFollow:FlxPoint;

	// notes
	public var renderedNotes:FlxTypedGroup<Note>;
	public var pendingNotes:List<Note> = new List<Note>();

	// public var strumNoteGroup:FlxTypedGroup<

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		gameCamera = new FlxCamera();
		hudCamera = new FlxCamera();
		hudCamera.bgColor.alpha = 0;

		FlxG.cameras.reset(gameCamera);
		FlxG.cameras.add(hudCamera);

		FlxG.cameras.setDefaultDrawTarget(gameCamera, true);

		persistentDraw = true;
		persistentUpdate = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
