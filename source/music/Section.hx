package music;

class Section {}

typedef SectionInfo =
{
	var notes:Array<NoteInfo>;
	var lengthInSteps:Int;
	var bpm:Float;
}

typedef NoteInfo =
{
	var strumTime:Float;
	var direction:Int;
	var sustain:Float;
	var noteAnim:String;
	var noteType:String;
}
