package backend.compat;

import music.Song;
import music.Song.SongInfo;
import music.Section;
import haxe.Json;

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
						} = Json.parse(fixData(chart));

					var convertedData:SongInfo = {
						song: baseJSON.song,
						sectionList: {notes: [], bpm: [], lengthInSteps: []},
						mustHitSections: [],
						bpm: baseJSON.bpm,
						speed: baseJSON.speed,
						player: baseJSON.player1,
						opponent: baseJSON.player2,
						spectator: 'gf'
					}

					for (section in baseJSON.notes)
					{
						var index:Int = baseJSON.notes.indexOf(section);

						convertedData.sectionList.bpm[index] = section.bpm;
						convertedData.sectionList.lengthInSteps[index] = section.lengthInSteps;

						for (notes in section.sectionNotes)
						{
							var noteIndex:Int = section.sectionNotes.indexOf(notes);

							convertedData.sectionList.notes[noteIndex] = {
								strumTime: notes[0],
								direction: Std.int(notes[1] % 4),
								sustain: notes[2],
								noteAnim: ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][Std.int(notes[1] % 4)],
								noteType: '',
							};
						}
					}

					return convertedData;
				}
		}

		return null;
	}
}
