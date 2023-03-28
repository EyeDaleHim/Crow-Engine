package weeks;

import haxe.Json;
import sys.FileSystem;
import openfl.Assets;

class WeekHandler
{
	public static function resetWeeks():Void
	{
		weeks = [];
		songs = [];

		var folder = Paths.getPathAsFolder("data/weeks");

		// grab all weeks in this folder
		if (FileSystem.exists(folder))
		{
			for (week in FileSystem.readDirectory(folder))
			{
				try
				{
					weeks.push(Json.parse(Assets.getText(Paths.data('weeks/$week'))));
				}
			}

			folder += '/songs';
		}

		for (week in weeks)
		{
			for (song in week.songs)
			{
				songs.push({
					name: song,
					color: week.defaultColor,
					icon: week.defaultIcon,
					defaultDifficulty: week.defaultDifficulty,
					difficulties: week.difficulties,
					parentWeek: week.name
				});
			}
		}

		// we don't expect it to appear anyway
		if (FileSystem.exists(folder))
		{
			for (song in FileSystem.readDirectory(folder))
			{
				if (findSongIndex(song) != -1)
					songs.push(Json.parse(Assets.getText(Paths.data('weeks/songs/$song'))));
			}
		}
	}

	public static var weeks:Array<WeekStructure> = [];
	public static var songs:Array<SongStructure> = [];


	public static var weekCharacters:Map<String, Array<String>> = [
		'tutorial' => ["", "boyfriend", "gf"],
		'week1' => ["dad", "boyfriend", "gf"],
		"week2" => ["spooky", "boyfriend", "gf"],
		"week3" => ["pico", "boyfriend", "gf"],
		"week4" => ["mom", "boyfriend", "gf"],
		"week5" => ["parents", "boyfriend", "gf"],
		"week6" => ["pixel", "boyfriend", "gf"],
		"week7" => ["tankman", "boyfriend", "gf"]
	];

	public static function findSongIndex(song:String):Int
	{
		for (i in 0...songs.length)
			{
				if (songs[i].name == song)
					return i;
			}
	
			return -1;
	}

	public static function findWeekIndex(week:String):Int
	{
		for (i in 0...weeks.length)
		{
			if (weeks[i].name == week)
				return i;
		}

		return -1;
	}

	public static function addSongToList(struct:SongStructure)
	{
		var weekIndex:Int = findWeekIndex(struct.parentWeek);

		if (weekIndex != -1)
		{
			var songList = weeks[weekIndex].songs;

			if (!songList.contains(struct.name))
				songList.push(struct.name);
		}

		songs.push(struct);
	}

	public static final DEFAULT_DIFFICULTIES:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static var defaultDifficulty:String = 'Normal';
}

// if a song file exists, song will overwrite the current week's default values
typedef SongStructure =
{
    var name:String;
    var color:Int;
    var icon:String;
    var difficulties:Array<String>;
    var defaultDifficulty:String;
    var parentWeek:String;
}

typedef WeekStructure =
{
	var name:String;
    var description:String;
	var songs:Array<String>;

    var displayCharacters:Array<String>;

	var defaultDifficulty:String;
    var difficulties:Array<String>;
	var defaultColor:Int;
	var defaultIcon:String;
}
