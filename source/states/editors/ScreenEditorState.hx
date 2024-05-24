package states.editors;

class ScreenEditorState extends MainState
{
	public static final list:Array<String> = ['Character Editor', 'Chart Editor', 'Stage Editor'];

	public static var curSelected:Int = 0;

	public static var characterEditor:CharacterEditorGroup;
	public static var chartEditor:ChartEditorGroup;
	public static var stageEditor:StageEditorGroup;

	public var selectedEditor:FlxContainer;

	public var topCamera:FlxCamera;

	public var editorItems:FlxTypedGroup<Alphabet>;

	override function create()
	{
		if (characterEditor == null)
			characterEditor = new CharacterEditorGroup();

		if (chartEditor == null)
			chartEditor = new ChartEditorGroup();

		if (stageEditor == null)
			stageEditor = new StageEditorGroup();

		topCamera = new FlxCamera();
		topCamera.bgColor.alpha = 0;
		FlxG.cameras.add(topCamera);

		editorItems = new FlxTypedGroup<Alphabet>();
		editorItems.camera = topCamera;
		add(editorItems);

		for (item in list)
		{
			var itemText:Alphabet = new Alphabet(4, 70 + (70 * list.indexOf(item)), item);
			itemText.alpha = 0.6;
			editorItems.add(itemText);

			FlxMouseEvent.add(itemText, function(spr)
			{
				clickSelection(item);
			}, null, function(spr)
			{
				spr.alpha = 1.0;
			}, function(spr)
			{
				spr.alpha = 0.6;
			});
		}

		bringUpEditors();
	}

	public function bringUpEditors():Void
	{
		topCamera.alpha = 0.0;
		editorItems.active = false;
		FlxTween.tween(topCamera, {alpha: 1.0}, 0.5, {
			onComplete: function(tween)
			{
				editorItems.active = true;
			}
		});
	}

	public function changeSelection(change:Int)
	{
	}

	public function clickSelection(editor:String):Void
	{
		switch (editor)
		{
			case 'Character Editor':
				{
					if (selectedEditor == null)
						insert(0, characterEditor);
					else
						replace(selectedEditor, characterEditor);

					selectedEditor = characterEditor;
				}
			case 'Chart Editor':
				{
					if (selectedEditor == null)
						insert(0, chartEditor);
					else
						replace(selectedEditor, chartEditor);

					selectedEditor = chartEditor;
				}
			case 'Stage Editor':
				{
					if (selectedEditor == null)
						insert(0, stageEditor);
					else
						replace(selectedEditor, stageEditor);

					selectedEditor = stageEditor;
				}
		}
	}

	override public function destroy()
	{
		remove(selectedEditor);
		selectedEditor = null;
		super.destroy();
	}
}
