package weeks;

class SongHandler
{
	// whatever better alternative to holding it in freeplay
	public static var songs:Map<String, Map<String, WeekList>> = [
		'Base_Game' => [
			'tutorial' => {
				songs: ['tutorial'],
				icons: ['gf'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFA5004D,
				index: 0
			},
			'week1' => {
				songs: ['Bopeebo', 'Fresh', 'Dad Battle'],
				icons: ['dad', 'dad', 'dad'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFB97BDD,
				index: 1,
				description: 'Daddy Dearest'
			},
			'week2' => {
				songs: ['Spookeez', 'South', 'Monster'],
				icons: ['spooky', 'spooky', 'monster'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFF1D5D7A,
				index: 2,
				description: 'Spooky Month'
			},
			'week3' => {
				songs: ['Pico', 'Philly Nice', 'Blammed'],
				icons: ['pico', 'pico', 'pico'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFF941653,
				index: 3,
				description: 'Pico'
			},
			'week4' => {
				songs: ['Satin Panties', 'High', 'Milf'],
				icons: ['mom', 'mom', 'mom'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFD8558E,
				index: 4,
				description: 'Mommy Must Murder'
			},
			'week5' => {
				songs: ['Cocoa', 'Eggnog', 'Winter Horrorland'],
				icons: ['parents', 'parents', 'monster'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFA0D1FF,
				index: 5,
				description: 'Red Snow'
			},
			'week6' => {
				songs: ['Senpai', 'Roses', 'Thorns'],
				icons: ['senpai', 'senpai', 'spirit'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFFF78BF,
				index: 6,
				description: 'Hating Simulator Ft. Moawling'
			},
			'week7' => {
				songs: ['Ugh', 'Guns', 'Stress'],
				icons: ['tankman', 'tankman', 'tankman'],
				diffs: PLACEHOLDER_DIFF,
				color: 0xFFF6B604,
				index: 7,
				description: 'Tankman'
			}
		]
	];

	public static var weekCharacters:Map<String, Array<String>> = [
		'tutorial' => ["", "bf", "gf"],
		'week1' => ["dad", "bf", "gf"],
		"week2" => ["spooky", "bf", "gf"],
		"week3" => ["pico", "bf", "gf"],
		"week4" => ["mom", "bf", "gf"],
		"week5" => ["parents", "bf", "gf"],
		"week6" => ["pixel", "bf", "gf"],
		"week7" => ["tankman", "bf", "gf"]
	];

	public static function getWeek(week:String):WeekList
	{
		if (songs['Base_Game'].exists(week))
			return songs['Base_Game'].get(week);

		return {
			songs: [],
			icons: [],
			diffs: PLACEHOLDER_DIFF,
			color: 0xFFFFFFFF,
			index: -1
		};
	}

	public static final PLACEHOLDER_DIFF:DiffList = ['Easy', 'Normal', 'Hard'];
	public static var defaultDifficulty:String = 'Normal';
}

typedef DiffList = Array<String>;

typedef WeekList =
{
	var songs:Array<String>;
	var icons:Array<String>;
	var diffs:DiffList;
	var color:Int;
	var index:Int;
	@:optional var description:String;
}
