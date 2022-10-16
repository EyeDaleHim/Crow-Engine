package music;

import music.Section.SectionInfo;

using StringTools;
using utils.Tools;

class Song
{
	public static var currentSong:SongInfo;

	public static function loadSong(song:String):SongInfo
	{
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
