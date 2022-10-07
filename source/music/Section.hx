package music;

class Section {}

typedef SectionInfo =
{
	var notes:Array<NoteInfo>;
	var lengthInSteps:Int;
	var bpm:Float;
	var changeBPM:Bool;
}

typedef NoteInfo =
{
	var strumTime:Float;
	var direction:Int;
	var sustain:Float;
	var noteAnim:String;
	var noteType:String;
}
