package objects.notes;

import flixel.FlxG;
import flixel.FlxSprite;
import backend.NoteStorageFunction;

class Note extends FlxSprite
{
	public static var earlyMult:Float = 0.5;

	public var direction:Int = 0;
	public var strumTime:Float = 0;
	public var strumOwner:Int = 0; // enemy = 0, player = 1, useful if you wanna make a pasta night / bonedoggle gimmick thing

	public var mustPress:Bool = false;
	public var canBeHit(get, null):Bool;
	public var tooLate(get, null):Bool;
	public var wasGoodHit(get, null):Bool;

	private function get_canBeHit():Bool
	{
		return (strumTime > Conductor.songPosition - NoteStorageFunction.safeZoneOffset
			&& strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult));
	}

	private function get_tooLate():Bool
	{
		return (strumTime < Conductor.songPosition - NoteStorageFunction.safeZoneOffset && !wasGoodHit);
	}

	private function get_wasGoodHit():Bool
	{
		return ((strumTime < Conductor.songPosition + (NoteStorageFunction.safeZoneOffset * earlyMult))
			&& (/*(isSustainNote && prevNote.wasGoodHit) ||*/ strumTime <= Conductor.songPosition));
	}
}
