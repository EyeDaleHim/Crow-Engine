package music;

import music.Section.SectionInfo;

class Song
{
	public var song:String;
	public var bpm:Float;
}

typedef SongInfo =
{
	var song:String;
	var notes:SectionInfo;
	var mustHitSections:Array<Bool>;
	var bpm:Float;

	var player:String;
	var opponent:String;
	var spectator:String; // fancy term for gf
}
