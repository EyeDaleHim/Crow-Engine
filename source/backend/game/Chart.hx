package backend.game;

class Chart
{
	public static function read(raw:ChartData):Array<Note>
	{
		try
		{
			var noteList:Array<Note> = [];

			for (note in raw.notes)
			{
				var rawNote:Array<Int> = null;

				if (note[0] == 0)
					rawNote = raw.cachedNotes[note[1]];
				else
					rawNote = note;

				var newNote:Note = new Note(rawNote[1], rawNote[2], rawNote[3], raw.noteTypes[rawNote[4]], rawNote[5]);
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
