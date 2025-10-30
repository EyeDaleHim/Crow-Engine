package gear.states.menus;

import gear.states.internals.BaseMenuState;

/**
 * While normally, you don't need a separate class to run a state since JSON files
 * are capable of abstracting away all the logic, however, classes like these are 
 * kept for stylistic purposes and convenience for any source-code programmers 
 * in the case of a Friday Night Funkin' mod.
 * 
 * In some cases, you want to code your own logic if you find JSON-based states
 * too hard. Keeping classes like these provide an insurance policy.
 */
class TitleState extends BaseMenuState
{
	public function new()
	{
		super();

		nextScenes = ["main_menu"];

		try
		{
			menuMetadata = cast Main.assets.json('data/menus/title');
		}
		catch (e)
		{
			trace('Error parsing title intro file: $e');
		}

		buildMenu();

		openCallback = onReturn;
	}

	public function onReturn():Void
	{
		onEvent("skipIntro");
	}
}
