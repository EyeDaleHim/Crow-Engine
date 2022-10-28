package objects.notes;

// noteskin shit
typedef NoteFile =
{
	var animDirections:Array<String>;
	var sustainAnimDirections:Array<{end:String, body:String}>;

	var animationData:Array<Animation>;
}

typedef StrumNoteFile =
{
	var pressAnim:Array<String>;
	var staticAnim:Array<String>;
	var confirmAnim:Array<String>;
	var animationData:Array<Animation>;
}

// in case i ever need to combine the files

typedef FullNoteFile =
{
	var noteFile:NoteFile;
	var strumFile:StrumNoteFile;
}
