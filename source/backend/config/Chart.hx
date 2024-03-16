package backend.config;

class Chart
{
	public static function read(content:String):Array<Note>
	{
		try
		{
			var raw:ChartData = cast Json.parse(content);
            var noteList:Array<Note> = [];

            for (note in raw.notes)
            {
                var direction:Int = note.bitData;
            }

            return noteList;
		} catch (e)
		{
            trace(e.toString());
		}

		return [];
	}
}
