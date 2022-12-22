package backend;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.notes.Note;

// Fixed the name for you Dale -LeX
class NoteStorageFunction
{
	public static var safeFrames:Float = 10.0;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000.0;

	// note: use getStoredNotes() because tradition
	public static var storedNotes:Map<Int, Map<Int, FlxTypedGroup<Note>>> = [0 => [], 1 => []];

	// doing this because i like making it robust
	public static function getStoredNotes(sustain:Bool = false, direction:Int = -1):FlxTypedGroup<Note>
	{
		var sustainValue:Int = 0;

		if (sustain)
			sustainValue = 1;

		if (direction == -1)
			return new FlxTypedGroup<Note>();

		if (storedNotes[sustainValue][direction] == null)
			storedNotes[sustainValue].set(direction, new FlxTypedGroup<Note>());

		return storedNotes[sustainValue][direction];
	}
}
