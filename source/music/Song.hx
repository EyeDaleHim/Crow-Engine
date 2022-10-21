package music;

import flixel.math.FlxMath;
import openfl.utils.Assets;
import haxe.Json;
import music.Section.SectionInfo;
import weeks.SongHandler;

using StringTools;
using utils.Tools;

class Song
{
	public static var currentSong:SongInfo;

	public static function loadSong(song:String, diff:Int = 2):SongInfo
	{
		var diffString:String = SongHandler.PLACEHOLDER_DIFF[Std.int(FlxMath.bound(diff, 0, 2))];

		try
		{
			var fixData:String->String = function(str:String)
			{
				while (!str.endsWith("}"))
				{
					str = str.substr(0, str.length - 1);
				}

				return str;
			};

			currentSong = Json.parse(fixData(Assets.getText(Paths.data('charts/' + song + '/' + song + '-' + diffString))));
		}
		catch (e)
		{
			throw 'Couldn\'t load song $song with difficulty $diffString';
		}

		return {
			song: song,
			sectionList: {
				notes: [],
				lengthInSteps: 16,
				bpm: 100
			},
			mustHitSections: [],
			bpm: 100,
			player: 'bf',
			opponent: 'dad',
			spectator: 'gf'
		};
	}
}

typedef SongInfo =
{
	var song:String;
	var sectionList:SectionInfo;
	var mustHitSections:Array<Bool>;
	var bpm:Float;

	var player:String;
	var opponent:String;
	var spectator:String; // fancy term for gf
}
