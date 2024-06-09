package system.gameplay;

class Chart
{
	public static function read(raw:ChartData):Array<Note>
	{
		try
		{
			var noteList:Array<Note> = [];

			for (note in raw.notes)
			{
				var newNote:Note = new Note(note[0], note[1].floor(), note[2].floor(), raw.noteTypes[note[3].floor()], note[4].floor());
				noteList.push(newNote);
			}

			return noteList;
		} catch (e)
		{
			trace(e.toString());
		}

		return [];
	}
}
