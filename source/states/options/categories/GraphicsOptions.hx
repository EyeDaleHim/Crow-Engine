package states.options.categories;

import states.options.OptionsMenu.CategoryOption;

class GraphicsOptions extends CategoryOptions
{
	// hopefully use a function instead of a variable to not use memory?
	public static function getOptions():Array<CategoryOption>
	{
		var options:Array<CategoryOption> = [];

		options.push({
			name: 'Frame Rate',
			description: 'How many frames should the game run at.',
			saveHolder: 'framerate',
			defaultValue: 0,
			choices: [60, 75, 90, 120, 144, 160, 240],
			type: 2
		});
		options.push({
			name: 'Antialiasing',
			description: 'Removes jagged edges of the game for an improved quality.',
			saveHolder: 'antialiasing',
			defaultValue: true,
			type: 0
		});
		options.push({
			name: 'Flashing Lights',
			description: 'Whether flashing lights should be on or off for photosensitive players.',
			saveHolder: 'flashing_lights',
			defaultValue: false,
			type: 0
		});

		return options;
	}
}
