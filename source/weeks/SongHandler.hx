package weeks;

class SongHandler
{
	// whatever better alternative to holding it in freeplay
	public static var songs:Map<String, Map<String, {songs:Array<String>, icons:Array<String>, index:Int}>> = [
		'Base_Game' => [
			'tutorial' => {songs: ['tutorial'], icons: ['gf'], index: 0},
			'week1' => {songs: ['Bopeebo', 'Fresh', 'Dad Battle'], icons: ['dad', 'dad', 'dad'], index: 1},
			'week2' => {songs: ['Spookeez', 'South', 'Monster'], icons: ['spooky', 'spooky', 'monster'], index: 2},
			'week3' => {songs: ['Pico', 'Philly Nice', 'Blammed'], icons: ['pico', 'pico', 'pico'], index: 3},
			'week4' => {songs: ['Satin Panties', 'High', 'Milf'], icons: ['mom', 'mom', 'mom'], index: 4},
			'week5' => {songs: ['Cocoa', 'Eggnog', 'Winter Horrorland'], icons: ['parents', 'parents', 'monster'], index: 5},
			'week6' => {songs: ['Senpai', 'Roses', 'Thorns'], icons: ['senpai', 'senpai', 'spirit'], index: 6},
			'week7' => {songs: ['Ugh', 'Guns', 'Stress'], icons: ['tankman', 'tankman', 'tankman'], index: 7}
		]
	];
}
