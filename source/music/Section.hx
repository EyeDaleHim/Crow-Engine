package music;

class Section {}

typedef SectionInfo =
{
	var notes:Array<NoteInfo>;
	var length:Int;
}

typedef NoteInfo =
{
	var strumTime:Float;
	var direction:Int;
	var sustain:Float;
	var mustPress:Bool;
	var noteAnim:String;
	var noteType:String;
}
