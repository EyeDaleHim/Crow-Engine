package states.editors;

class ScreenEditorState extends MainState
{
	public static final list:Array<String> = ['Character Editor', 'Chart Editor', 'Stage Editor'];

	public static var isActive:Bool = false;

	public static var curSelected:Int = 0;

	public static var characterEditor:CharacterEditorGroup;
	public static var chartEditor:ChartEditorGroup;
	public static var stageEditor:StageEditorGroup;

	public var selectedEditor:FlxContainer;

	public var topCamera:FlxCamera;

	public var editorItems:FlxTypedGroup<Button>;

	override function create()
	{
		isActive = true;

		if (characterEditor == null)
			characterEditor = new CharacterEditorGroup();

		if (chartEditor == null)
			chartEditor = new ChartEditorGroup();

		if (stageEditor == null)
			stageEditor = new StageEditorGroup();

		topCamera = new FlxCamera();
		topCamera.bgColor.alpha = 0;
		FlxG.cameras.add(topCamera);

		editorItems = new FlxTypedGroup<Button>();
		editorItems.camera = topCamera;
		add(editorItems);

		for (item in list)
		{
			var itemText:Button = new Button(10, 30 + (30 * list.indexOf(item)), null, {autoSize: XY, fontSize: 16, font: "vcr"}, item);
			editorItems.add(itemText);

			FlxMouseEvent.add(itemText, function(spr)
			{
				if (editorItems.active)
					clickSelection(item);
			}, null, function(spr)
			{
				if (editorItems.active)
					spr.alpha = 1.0;
			}, function(spr)
			{
				if (editorItems.active)
					spr.alpha = 0.6;
			});
		}

		bringUpEditors();
	}

	public var editorActive:Bool = true;

	public function bringUpEditors():Void
	{
		editorActive = true;

		FlxTween.cancelTweensOf(topCamera);

		topCamera.alpha = 0.0;
		editorItems.active = false;
		editorItems.forEach(function(spr:Button)
		{
			spr.exists = true;
		});
		FlxTween.tween(topCamera, {alpha: 1.0}, 0.2, {
			onComplete: function(tween)
			{
				editorItems.active = true;
			}
		});
	}

	public function closeEditors():Void
	{
		editorActive = false;

		FlxTween.cancelTweensOf(topCamera);

		topCamera.alpha = 1.0;
		editorItems.active = false;
		FlxTween.tween(topCamera, {alpha: 0.0}, 0.2, {
			onComplete: function(tween)
			{
				editorItems.forEach(function(spr:Button)
				{
					spr.exists = false;
				});
			}
		});
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
		isActive = false;

		remove(selectedEditor);
		selectedEditor = null;
		super.destroy();
	}
}
