package backend.compat;

import music.Song;
import music.Song.SongInfo;
import music.Section;
import tjson.TJSON as Json;

using StringTools;

class ChartConvert
{
	// public static function convertFrom(chart:Song.SongInfo, version:Int) {}
	public static function convertType(type:String, chart:String):SongInfo
	{
		var fixData:String->String = function(str:String)
		{
			while (!str.endsWith("}"))
			{
				str = str.substr(0, str.length - 1);
			}

			return str;
		};

		switch (type)
		{
			case 'base':
				{
					var baseJSON:
						{
							song:
								{
									song:String,
									notes:Array<{
										sectionNotes:Array<Dynamic>,
										lengthInSteps:Int,
										typeOfSection:Int,
										mustHitSection:Bool,
										bpm:Int,
										changeBPM:Bool,
										altAnim:Bool,
									}>,
									bpm:Int,
									needsVoices:Bool,
									speed:Float,

									player1:String,
									player2:String,
									validScore:Bool,
								}
						} = Json.parse(fixData(chart));

					var convertedData:SongInfo = {
						song: baseJSON.song.song,
						sectionList: [],
						mustHitSections: [],
						bpmMapping: [],
						bpm: baseJSON.song.bpm,
						speed: baseJSON.song.speed,
						player: baseJSON.song.player1,
						opponent: baseJSON.song.player2,
						spectator: 'gf',
						extraData: []
					}

					var totalSteps:Int = 0;

					for (section in baseJSON.song.notes)
					{
						var index:Int = baseJSON.song.notes.indexOf(section);

						convertedData.sectionList[index] = {notes: [], length: 16};
						convertedData.sectionList[index].length = section.lengthInSteps;
						convertedData.mustHitSections[index] = section.mustHitSection;

						var deltaSteps:Int = section.lengthInSteps;
						totalSteps += deltaSteps;

						if (section.changeBPM && section.bpm != convertedData.bpm)
						{
							convertedData.bpmMapping.push({step: totalSteps, bpm: section.bpm});
						}

						for (notes in section.sectionNotes)
						{
							var noteIndex:Int = section.sectionNotes.indexOf(notes);
							var gottaHitNote:Bool = section.mustHitSection;
							if (notes[1] > 3)
								gottaHitNote = !gottaHitNote;

							var noteAnim:String = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][Std.int(notes[1] % 4)];

							if (notes[3])
								noteAnim += '-alt';

							convertedData.sectionList[index].notes[noteIndex] = {
								strumTime: notes[0],
								direction: Std.int(notes[1] % 4),
								mustPress: gottaHitNote,
								sustain: notes[2],
								noteAnim: noteAnim,
								noteType: '',
							};

							if (section.altAnim)
							{
								convertedData.sectionList[index].notes[noteIndex].noteAnim += '-alt';
							}
						}
					}

					return convertedData;
				}
		}

		return null;
	}
}
