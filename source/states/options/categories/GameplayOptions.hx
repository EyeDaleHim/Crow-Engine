package states.options.categories;

import states.options.OptionsMenu.CategoryOption;

class GameplayOptions extends CategoryOptions
{
	// hopefully use a function instead of a variable to not use memory?
	public static function getOptions():Array<CategoryOption>
	{
		var options:Array<CategoryOption> = [];

		options.push({
			name: 'Downscroll',
			description: 'If enabled, the notes will scroll downwards.',
			saveHolder: 'downscroll',
			defaultValue: false,
			type: 0
		});
		options.push({
			name: 'Ghost Tap',
			description: 'Allows you to make inputs that are not called for while playing a song.',
			saveHolder: 'ghost_tap',
			defaultValue: true,
			type: 0
		});
		options.push({
			name: 'Camera Zooming',
			description: 'If the camera should zoom in a little every section.',
			saveHolder: 'camZoom',
			defaultValue: true,
			type: 0
		});

		return options;
	}
}
