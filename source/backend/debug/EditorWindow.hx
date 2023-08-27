package backend.debug;

// windows for editors, should make life easier

class EditorWindow extends FlxTypedSpriteGroup<FlxSprite>
{
	private var _close:FlxSprite;
	private var _minimize:FlxSprite;

	private var _titleBar:FlxSprite;
	private var _titleText:FlxText;

	private function minimize():Void
	{
		var ignoreMember:Array<FlxObject> = [_close, _minimize, _titleBar, _titleText];

		for (object in members)
		{
			if (!ignoreMember.contains(object))
			{
				// make members invisible
			}
		}
	}
}
