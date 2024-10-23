package system.gameplay;

class Chart
{
	public static function readNotes(raw:ChartData):Array<Note>
	{
		try
		{
			var noteList:Array<Note> = [];

			for (note in raw.notes)
			{
				var newNote:Note = new Note(note[0], note[1].floor(), note[2].floor(), raw.noteTypes[note[3].floor()], note[4].floor());
				noteList.push(newNote);
			}

			noteList.sort((note1:Note, note2:Note) -> {
				return FlxSort.byValues(FlxSort.ASCENDING, note1.strumTime, note2.strumTime);
			});

			return noteList;
		} catch (e)
		{
			trace(e.toString());
		}

		return [];
	}
}
