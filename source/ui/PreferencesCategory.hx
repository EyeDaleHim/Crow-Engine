package ui;

import flixel.FlxG;

class PreferencesCategory extends Page
{
	var items:TextMenuList;

	override public function new()
	{
		super();
		add(items = new TextMenuList());
		createItem('gameplay', function()
		{
			onSwitch.dispatch(PageName.Preferences);
		});
		createItem('graphics', function()
		{
			onSwitch.dispatch(PageName.Controls);
		});
		createItem('back', function()
		{
			onSwitch.dispatch(PageName.Options);
		}, true);
	}

	public function createItem(label:String, callback:Dynamic, ?fireInstantly:Bool = false)
	{
		var item:TextMenuItem = items.createItem(0, 100 + 100 * items.length, label, Bold, callback);
		item.fireInstantly = fireInstantly;
		item.screenCenter(X);
		return item;
	}

	override function set_enabled(state:Bool)
	{
		items.enabled = state;
		return super.set_enabled(state);
	}
}
