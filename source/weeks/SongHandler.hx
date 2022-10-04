package weeks;

class SongHandler
{
	// whatever better alternative to holding it in freeplay
	public static var songs:Map<String, Map<String, WeekList>> = [
		'Base_Game' => [
			'tutorial' => {
				songs: ['tutorial'],
				icons: ['gf'],
				color: 0xFFA5004D,
				index: 0
			},
			'week1' => {
				songs: ['Bopeebo', 'Fresh', 'Dad Battle'],
				icons: ['dad', 'dad', 'dad'],
				color: 0xFFB97BDD,
				index: 1
			},
			'week2' => {
				songs: ['Spookeez', 'South', 'Monster'],
				icons: ['spooky', 'spooky', 'monster'],
				color: 0xFF1D5D7A,
				index: 2
			},
			'week3' => {
				songs: ['Pico', 'Philly Nice', 'Blammed'],
				icons: ['pico', 'pico', 'pico'],
				color: 0xFF941653,
				index: 3
			},
			'week4' => {
				songs: ['Satin Panties', 'High', 'Milf'],
				icons: ['mom', 'mom', 'mom'],
				color: 0xFFD8558E,
				index: 4
			},
			'week5' => {
				songs: ['Cocoa', 'Eggnog', 'Winter Horrorland'],
				icons: ['parents', 'parents', 'monster'],
				color: 0xFFA0D1FF,
				index: 5
			},
			'week6' => {
				songs: ['Senpai', 'Roses', 'Thorns'],
				icons: ['senpai', 'senpai', 'spirit'],
				color: 0xFFFF78BF,
				index: 6
			},
			'week7' => {
				songs: ['Ugh', 'Guns', 'Stress'],
				icons: ['tankman', 'tankman', 'tankman'],
				color: 0xFFF6B604,
				index: 7
			}
		]
	];
}

typedef WeekList =
{
	var songs:Array<String>;
	var icons:Array<String>;
	var color:Int;
	var index:Int;
}
