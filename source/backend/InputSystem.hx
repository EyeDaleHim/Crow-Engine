package backend;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.notes.Note;

// cant tell if i should really call this an input system if it just stores note stufs
class InputSystem
{
	public static var safeFrames:Float = 10.0;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000.0;

	// note: use getStoredNotes() because tradition
	public static var storedNotes:Map<Bool, Map<Int, FlxTypedGroup<Note>>> = [false => [], true => []];

	// doing this because i like making it robust
	public static function getStoredNotes(sustain:Bool = false, direction:Int = -1):FlxTypedGroup<Note>
	{
		if (direction == -1)
			return new FlxTypedGroup<Note>();

		if (storedNotes[sustain][direction] == null)
			storedNotes[sustain].set(direction, new FlxTypedGroup<Note>());

		return storedNotes[sustain][direction];
	}
}
