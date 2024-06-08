package system.gameplay;

// save yourself the hassle and just use crow engine format
class ChartConverter
{
	// some overhead since it wants to guarantee the chart it wants to use
	public static function classifyChart(data:Dynamic):ChartTypes
	{
		var chartStruct:Array<Dynamic> = [];

		// 2. PSYCH
		if (data.gfVersion != null || data.player3 != null)
			return PSYCH;

		chartStruct.splice(0, chartStruct.length);

		// 3. BASE LEGACY
		chartStruct.push(data.song);
		chartStruct.push(data.notes);
		chartStruct.push(data.bpm);
		chartStruct.push(data.needsVoices);
		chartStruct.push(data.speed);

		chartStruct.push(data.player1);
		chartStruct.push(data.player2);
		chartStruct.push(data.validScore);

		if (_checkList(chartStruct))
		{
			return BASE_LEGACY;
		}

		chartStruct.splice(0, chartStruct.length);

		// 4. BASE WEEKEND V1
		if (data.generatedBy != null)
			return BASE_WEEKEND_V1;

		return UNKNOWN;
	}

	public static function convertBaseLegacyToCrow(data:Dynamic):ChartData
	{
		throw "Not implemented";
	}

	public static function convertWeekendToCrow(data:Dynamic, difficulty:String):ChartData
	{
		throw "Not implemented";
	}

	public static function convertPsychToCrow(data:Dynamic):ChartData
	{
		throw "Not implemented";
	}

	private static function _checkList(struct:Array<Dynamic>):Bool
	{
		for (data in struct)
		{
			if (data == null)
				return false;
		}
		return true;
	}
}

enum abstract ChartTypes(Int)
{
	var UNKNOWN:ChartTypes = -1;

	var CROW:ChartTypes = 0;

	var BASE_LEGACY:ChartTypes = 1;
	var BASE_WEEKEND_V1:ChartTypes = 2;

	var PSYCH:ChartTypes = 3;
}
