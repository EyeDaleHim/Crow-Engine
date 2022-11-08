package states.options;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.keyboard.FlxKey;
import states.options.DescriptionHolder;
import states.options.OptionsCategoryType;
import objects.Alphabet;

class OptionsMenu extends MusicBeatState
{
	public var onSwitch:FlxTypedSignal<OptionsCategoryType->Void> = new FlxTypedSignal<OptionsCategoryType->Void>();

	private var mainCategory:Array<CategoryInfo> = [
		{name: 'gameplay', description: 'Change the overall gameplay of your game.'},
		{name: 'graphics', description: 'Change the game\'s appearance.'},
		{name: 'controls', description: 'Change the controls to your liking.'},
		{name: 'notes', description: 'Change the note\'s appearance in-game.'}
	];

	// sprites and stuff, automatically handled
	public var background:FlxSprite;
	public var dimmer:FlxSprite;

	public var title:Alphabet;
	public var categoryTitle:FlxSprite;
	public var description:DescriptionHolder;
	public var groupCategory:FlxTypedGroup<OptionsSprite>;

	public var globalGroupManager:FlxTypedGroup<FlxObject>;

	public var category:OptionsCategoryType;
	public var categoryID:Int = -1;

	public var curSelected:Array<Null<Int>> = [];

	override function create()
	{
		background = new FlxSprite().loadGraphic(Paths.image('menus/settingsBG'));
		background.scrollFactor.set();
		add(background);

		description = new DescriptionHolder();
		description.text = 'test test boogie boogie';

		globalGroupManager = new FlxTypedGroup<FlxObject>();

		add(globalGroupManager);
		add(description);

		createCategory();
		changeSelection(0, [], false);

		super.create();
	}

	public function createCategory(id:Int = -1)
	{
		globalGroupManager.clear();

		if (id == -1)
		{
			for (i in 0...mainCategory.length)
			{
				var category = mainCategory[i];

				var categoryText:Alphabet = new Alphabet(0, 0, category.name, true);
				categoryText.y = 350 + ((categoryText.height + 20) * i);
				categoryText.screenCenter(X);
				categoryText.scrollFactor.set();
				categoryText.attributes.set('description', category.description);
				categoryText.ID = i;
				globalGroupManager.add(categoryText);
			}
		}
	}

	private var manualLerpPoint:FlxPoint = FlxPoint.get();
	private var _lerpTarget:Int = 0;

	override function update(elapsed:Float)
	{
		var lerpValue:Float = elapsed * 7.725;
		var lerpTowards:FlxPoint = new FlxPoint();

		switch (_lerpTarget)
		{
			case 0:
				lerpTowards = new FlxPoint(Math.min(FlxG.mouse.screenX + 24, FlxG.width - description.width - 8),
					Math.min(FlxG.mouse.screenY + 32, FlxG.height - description.height - 8));

				lerpTowards.set(Math.max(8, lerpTowards.x), Math.max(8, lerpTowards.y));

				lerpValue = elapsed * Math.max(FlxMath.remapToRange(new FlxPoint(description.x, description.y).distanceTo(lerpTowards), 150, 450, 7.725,
					15.775), 7.725);
			case 1:
				manualLerpPoint.copyTo(lerpTowards);
		}

		description.setPosition(Tools.lerpBound(description.x, lerpTowards.x, lerpValue), Tools.lerpBound(description.y, lerpTowards.y, lerpValue));

		if (FlxG.mouse.justMoved)
		{
			_lerpTarget = 0;

			switch (categoryID)
			{
				case -1:
					{
						for (category in globalGroupManager.members)
						{
							if (category.ID != curSelected[0])
							{
								if (FlxG.mouse.overlaps(category))
								{
									changeSelection(category.ID, [], true);
									break;
								}
							}
						}
					}
			}
		}

		if (controls.getKey('BACK', JUST_PRESSED))
		{
			if (categoryID == -1)
				MusicBeatState.switchState(new states.menus.MainMenuState());
		}
		else if (controls.getKey('ACCEPT', JUST_PRESSED))
		{
			if (categoryID == -1)
				trace("Pressed Enter"); // I Put This Here To Prevent Errors.
		}
		else
		{
			@:privateAccess
			{
				switch (categoryID)
				{
					case -1:
						{
							if (controls.getKey('UI_UP', JUST_PRESSED))
							{
								changeSelection(-1, controls.LIST_CONTROLS['UI_DOWN'].__keys);
							}
							else if (controls.getKey('UI_DOWN', JUST_PRESSED))
							{
								changeSelection(1, controls.LIST_CONTROLS['UI_DOWN'].__keys);
							}
						}
				}
			}
		}

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0, keys:Array<Int>, mouse:Bool = false)
	{
		if (curSelected[categoryID + 1] == null)
			curSelected[categoryID + 1] = 0;

		var curSelection:Int = curSelected[categoryID + 1];

		if (!mouse)
			curSelection = FlxMath.wrap(curSelection + change, 0, globalGroupManager.members.length - 1);
		else
			curSelection = FlxMath.wrap(change, 0, globalGroupManager.members.length - 1);

		curSelected[categoryID + 1] = curSelection;

		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		var keyDirection:Int = FlxKey.NONE;

		for (key in keys)
		{
			if (keyDirection == -1)
				keyDirection = getKeyDirection(key);
			else
				break;
		}

		@:privateAccess
		description._controlledAlpha = 0.7;
		description.targetAlpha = 1.0;

		switch (categoryID)
		{
			case -1:
				{
					for (text in globalGroupManager.members)
					{
						var textObj:Alphabet = cast(text, Alphabet);

						if ((mouse && FlxG.mouse.overlaps(textObj)) || (!mouse && textObj.ID == curSelection))
						{
							description.text = textObj.attributes['description'];
							textObj.alpha = 1.0;

							if (!mouse)
							{
								manualLerpPoint.set(textObj.x + 100, textObj.y + textObj.height + 10);
								_lerpTarget = 1;
							}
						}
						else
							textObj.alpha = 0.6;
					}
				}
			case 0 | 1:
				{}
			case 2:
				{}
			case 3:
				{}
		}
	}

	private function getKeyDirection(key:Int)
	{
		var controlList:Array<Array<FlxKey>> = [];
		@:privateAccess
		{
			controlList = [
				controls.LIST_CONTROLS['UI_LEFT'].__keys,
				controls.LIST_CONTROLS['UI_DOWN'].__keys,
				controls.LIST_CONTROLS['UI_UP'].__keys,
				controls.LIST_CONTROLS['UI_RIGHT'].__keys,
			];
		}

		if (key != FlxKey.NONE)
		{
			for (i in 0...controlList.length)
			{
				for (j in 0...controlList[i].length)
				{
					if (controlList[i][j] == key)
						return i;
				}
			}
		}

		return -1;
	}
}

@:allow(states.options.OptionsMenu)
class OptionsSprite extends FlxTypedSpriteGroup<FlxSprite>
{
	public var name:String = '';
	public var saveHolder:String = '';
	public var description:String = '';

	private var _background:FlxSprite;
	private var _nameSprite:FlxText;

	// bool
	private var _isAccepted:Bool;
	private var _statsText:FlxText; // on, off

	// float, int
	private var _arrowLeft:FlxText;
	private var _arrowRight:FlxText;
	private var _numText:FlxText;

	private var __type:Int = -1;

	override function new(name:String, saveHolder:String, description:String)
	{
		super();
	}
}

typedef CategoryInfo =
{
	var name:String;
	var description:String;
}
