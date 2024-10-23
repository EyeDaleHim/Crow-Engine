package system.gameplay;

// save yourself the hassle and just use crow engine format
class ChartConverter
{
	// some overhead since it wants to guarantee the chart it wants to use
	public static function classifyChart(data:Dynamic):ChartTypes
	{
		var chartStruct:Array<Dynamic> = [];

		try
		{
			// 1. CROW
			if (data.crowIdentifer != null)
				return CROW;

			// 2. PSYCH V1
			if (data.song.format != null && data.song.format == "psych_v1_convert")
				return PSYCH_V1;

			// 3. PSYCH
			trace(data.song.gfVersion);
			if (data.song.gfVersion != null)
				return PSYCH;

			// 4. BASE LEGACY
			chartStruct.push(data.song.song);
			chartStruct.push(data.song.notes);
			chartStruct.push(data.song.bpm);
			chartStruct.push(data.song.needsVoices);
			chartStruct.push(data.song.speed);

			chartStruct.push(data.song.player1);
			chartStruct.push(data.song.player2);
			chartStruct.push(data.song.validScore);

			if (_checkList(chartStruct))
			{
				return BASE_LEGACY;
			}

			chartStruct.splice(0, chartStruct.length);

			// 5. BASE WEEKEND V1
			if (data.generatedBy != null)
				return BASE_WEEKEND_V1;
		} catch (e)
		{
			return UNKNOWN;
		}

		return UNKNOWN;
	}

	public static function classifyAndConvert(data:Dynamic):ChartData
	{
		var type:ChartTypes = ChartConverter.classifyChart(data);

		if (type == CROW)
			return data;

		if (type == BASE_LEGACY)
			return convertBaseLegacyToCrow(data);

		if (type == PSYCH_V1)
			return convertPsychToCrow(data, true);

		if (type == PSYCH)
			return convertPsychToCrow(data, false);

		if (type == BASE_WEEKEND_V1)
			return convertWeekendToCrow(data, 'hard');

		return WeekManager.emptyChart;
	}

	public static function convertBaseLegacyToCrow(data:Dynamic):ChartData
	{
		trace("Not implemented");
		return {};
	}

	public static function convertWeekendToCrow(data:Dynamic, difficulty:String):ChartData
	{
		trace("Not implemented");
		return {};
	}

	public static function convertPsychToCrow(data:Dynamic, isV1:Bool = false):ChartData
	{
		var chartData:ChartData = {};

		try
		{
			chartData.overrideMeta = {};
			chartData.notes = [];
			chartData.noteTypes = [];
			chartData.events = [];

			var sections:Array<Dynamic> = data.song.notes;
			var lastSectionHit:Null<Bool> = null;
			for (section in sections)
			{
				if (section.mustHitSection != lastSectionHit)
				{
					chartData.events.push({
						name: 'Focus Camera',
						contexts: [section.mustHitSection ? "player" : "opponent"],
						time: Conductor.getTimeAtMeasure(sections.indexOf(section), data.song.bpm)
					});
				}

				if (section.sectionNotes?.length > 0)
				{
					var sectionNotes:Array<Array<Dynamic>> = section.sectionNotes;
					for (dataNote in sectionNotes)
					{
						var note:Array<Float> = [];
						note[0] = dataNote[0];
						note[1] = (Math.floor(dataNote[1]) % 4);

						var gottaHitNote:Bool = section.mustHitSection;

						if (!isV1 && dataNote[1] > 3)
						{
							gottaHitNote = !section.mustHitSection;
						}

						if (gottaHitNote)
							note[2] = 1;
						else
							note[2] = 0;

						if (dataNote[3] != null)
						{
							if (!chartData.noteTypes.contains(dataNote[3]))
								chartData.noteTypes.push(dataNote[3]);
							note[3] = chartData.noteTypes.indexOf(dataNote[3]);
						}
						note[4] = dataNote[2];

						chartData.notes.push(note);
					}
				}
			}

			chartData.strumList = {
				controlledStrums: [1],
				list: [
					{length: 4, associatedChannel: "Voices-dad"},
					{length: 4, associatedChannel: "Voices-bf"}
				]
			};

			chartData.overrideMeta = {
				characters: {
					players: [data.song.player1 ?? "bf"],
					spectators: [data.song.gfVersion ?? "gf"],
					opponents: [data.song.player2 ?? "dad"]
				},
				speed: data.song.speed,
				bpm: data.song.bpm,
				stage: data.song.stage,
				channels: ['Inst', 'Voices']
			};

			chartData.crowIdentifer = 0;
		} catch (e)
		{
			trace(e.message);
			chartData = {};
		}

		return chartData;
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
	var PSYCH_V1:ChartTypes = 4;
}
