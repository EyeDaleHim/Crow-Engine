package system;

class DataManager
{
	public static final songHash:Map<String, SongDisplayData> = new Map();

	public static final weekList:Array<WeekMetadata> = [];

	public static final loadedCharts:Map<String, ChartData> = [];

	public static function importWeekFile(weekName:String)
	{
		try
		{
			var weekLocation:String = 'data/weeks/$weekName.json';
			if (FileSystem.exists(Assets.assetPath(weekLocation)))
			{
			var rawData:String = Assets.readText(Assets.assetPath(weekLocation));

			if (rawData.length == 0)
			{
				FlxG.log.error('Could not load week $weekName, please check ${Assets.assetPath(weekLocation)} if the data is correct.');
				return;
			}

			var weekData:WeekMetadata = cast Json.parse(rawData);
			weekList.push(weekData);
		}
		else
			FlxG.log.error('Could not load week $weekName, please check ${Assets.assetPath(weekLocation)}');
		} catch (e)
		{
			trace(e.toString());
		}
	}
}
