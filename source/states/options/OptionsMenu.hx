package states.options;

import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.input.keyboard.FlxKey;
import states.options.DescriptionHolder;
import states.options.categories.CategoryOptions;
import states.options.categories.GameplayOptions;
import states.options.categories.GraphicsOptions;

// god this code is so horrible
class OptionsMenu extends MusicBeatState
{
	private var mainCategory:Array<CategoryInfo> = [
		{name: 'gameplay', description: 'Change the overall gameplay of your game.'},
		{name: 'graphics', description: 'Change the game\'s appearance.'},
		{name: 'controls', description: 'Change the controls to your liking.'} // ,
		// {name: 'notes', description: 'Change the note\'s appearance in-game.'}
	];

	public static var changedSettings:Bool = false;

	// sprites and stuff, automatically handled
	public var background:FlxSprite;
	public var dimmer:FlxSprite;

	public var title:Alphabet;
	public var categoryTitle:FlxSprite;
	public var description:DescriptionHolder;
	public var groupCategory:FlxTypedGroup<OptionsSprite>;

	public var globalGroupManager:FlxTypedGroup<FlxSprite>;

	public var categoryID:Int = -1;

	public var curSelected:Array<Null<Int>> = [];

	override function create()
	{
		background = new FlxSprite().loadGraphic(Paths.image('menus/settingsBG'));
		background.scrollFactor.set();
		add(background);

		dimmer = new FlxSprite().makeGraphic(FlxG.width, Std.int(FlxG.height * 0.9), FlxColor.BLACK);
		dimmer.scrollFactor.set();
		dimmer.screenCenter();
		dimmer.alpha = 0.3;
		add(dimmer);

		description = new DescriptionHolder();
		description.text = ' ';

		globalGroupManager = new FlxTypedGroup<FlxSprite>();

		categoryTitle = new FlxSprite(0, 100);
		categoryTitle.frames = Paths.getSparrowAtlas('menus/mainmenu/menu_options');

		categoryTitle.animation.addByPrefix('selected', 'options white', 12);
		categoryTitle.animation.play('selected');
		categoryTitle.scale.set(0.8, 0.8);
		categoryTitle.updateHitbox();
		categoryTitle.screenCenter(X);

		add(globalGroupManager);
		add(categoryTitle);
		add(description);

		createCategory();
		changeSelection(0, [], false);

		super.create();
	}

	public function createCategory(id:Int = -1)
	{
		categoryID = id;
		globalGroupManager.clear();

		if (id == -1)
		{
			for (i in 0...mainCategory.length)
			{
				var category = mainCategory[i];

				var categoryText:Alphabet = new Alphabet(0, 0, category.name, true);
				categoryText.y = 250 + ((categoryText.height + 20) * i);
				categoryText.screenCenter(X);
				categoryText.scrollFactor.set();
				categoryText.attributes.set('description', category.description);
				categoryText.ID = i;
				globalGroupManager.add(categoryText);
			}
		}
		else
		{
			switch (categoryID)
			{
				case 0 | 1:
					{
						var fromOptions:Array<CategoryOption> = null;

						switch (categoryID)
						{
							case 0:
								fromOptions = GameplayOptions.getOptions();
							case 1:
								fromOptions = GraphicsOptions.getOptions();
						}

						if (fromOptions == null)
						{
							createCategory(-1);
							return;
						}

						for (member in fromOptions)
						{
							var i:Int = fromOptions.indexOf(member);

							var spriteMember:OptionsSprite = new OptionsSprite(member.name, member.saveHolder, member.description, member.defaultValue,
								member.bound, member.choices, member.type);
							spriteMember.ID = i;
							spriteMember.setPosition(40, dimmer.y + 80 + ((spriteMember.height + 10) * i));
							spriteMember.screenCenter(X);
							globalGroupManager.add(spriteMember);
						}
					}
				case 2:
					{
						var sortedControls:Array<String> = [];

						for (key => member in controls.LIST_CONTROLS)
						{
							sortedControls[member.id] = key;
						}

						// what the fuck??
						sortedControls.remove(sortedControls[sortedControls.length - 1]);

						for (member in sortedControls)
						{
							var i:Int = sortedControls.indexOf(member);

							var spriteMember:OptionsSprite = new OptionsSprite(member, '#CONTROL_$member', '', null, null, null, 3);
							spriteMember.ID = spriteMember.selectionIndex = i;
							spriteMember.setPosition(40, dimmer.y + 80 + ((spriteMember.height + 10) * i));
							spriteMember.screenCenter(X);
							globalGroupManager.add(spriteMember);
						}
					}
			}
		}

		description.visible = categoryID != 2;

		disableControlTimer = 0.25;
	}

	override function update(elapsed:Float)
	{
		description.setPosition(Math.min(FlxG.mouse.screenX + 24, FlxG.width - description.width - 8),
			Math.min(FlxG.mouse.screenY + 32, FlxG.height - description.height - 8));

		if (disableControlTimer <= 0.0)
		{
			if (FlxG.mouse.justMoved && (categoryID != 2 || (categoryID == 2 && FlxG.mouse.justPressed)))
			{
				for (category in globalGroupManager.members)
				{
					if (category.ID != curSelected[categoryID + 1])
					{
						if (FlxG.mouse.overlaps(category))
						{
							changeSelection(category.ID, [], true);
							break;
						}
					}
				}

				if (categoryID != -1)
				{
					if (!FlxG.mouse.overlaps(globalGroupManager.members[curSelected[categoryID + 1]]))
						cast(globalGroupManager.members[curSelected[categoryID + 1]], OptionsSprite).isSelected = false;
				}
			}

			var currentObj:FlxSprite = globalGroupManager.members[curSelected[categoryID + 1]];

			if (controls.getKey('BACK', JUST_PRESSED))
			{
				if (categoryID == -1)
					MusicBeatState.switchState(new states.menus.MainMenuState());
				else
				{
					createCategory(-1);
					changeSelection(0, [], false);

					categoryTitle.visible = true;
				}
			}
			else if (controls.getKey('ACCEPT', PRESSED) || (currentObj != null && FlxG.mouse.pressed && FlxG.mouse.overlaps(currentObj)))
			{
				@:privateAccess
				{
					switch (categoryID)
					{
						case -1:
							{
								if (controls.getKey('ACCEPT', JUST_PRESSED) || FlxG.mouse.justPressed)
								{
									categoryTitle.visible = false;
									createCategory(curSelected[0]);

									description._controlledAlpha = 0.0;
									description.targetAlpha = 0.0;
								}
							}
						case 0 | 1 | 2:
							{
								var optionsSprite:OptionsSprite = cast(currentObj, OptionsSprite);

								switch (optionsSprite.__type)
								{
									case 0:
										{
											if (controls.getKey('ACCEPT', JUST_PRESSED) || FlxG.mouse.justPressed)
												optionsSprite.onChange(!optionsSprite._isAccepted);
										}
									case 1 | 2:
										{
											/*if (!FlxG.mouse.pressed)
												{
													if (controls.getKey('UI_LEFT', JUST_PRESSED))
														optionsSprite.onChange(-5);
													else if (controls.getKey('UI_RIGHT', JUST_PRESSED))
														optionsSprite.onChange(5);

													optionsSprite._holdCooldown = 0.0;
												}
												else */

											if (optionsSprite._holdCooldown <= 0.0)
											{
												if (FlxG.mouse.overlaps(optionsSprite._arrowLeft))
													optionsSprite.onChange(-1);
												else if (FlxG.mouse.overlaps(optionsSprite._arrowRight))
													optionsSprite.onChange(1);

												optionsSprite._holdCooldown = 0.175;
											}
											else if (controls.getKey('UI_LEFT', JUST_PRESSED) || controls.getKey('UI_RIGHT', JUST_PRESSED))
											{
												if (controls.getKey('UI_LEFT', JUST_PRESSED))
													optionsSprite.onChange(-1);
												else if (controls.getKey('UI_RIGHT', JUST_PRESSED))
													optionsSprite.onChange(1);
											}
										}
									case 3:
										{
											optionsSprite.onChange(null);
										}
								}
							}
					}

					changeSelection(0, [], false);
				}
			}
			else
			{
				@:privateAccess
				{
					if (controls.getKey('UI_UP', JUST_PRESSED))
					{
						changeSelection(-1, controls.LIST_CONTROLS['UI_UP'].__keys);
					}
					else if (controls.getKey('UI_DOWN', JUST_PRESSED))
					{
						changeSelection(1, controls.LIST_CONTROLS['UI_DOWN'].__keys);
					}

					switch (categoryID)
					{
						case 2:
							{
								if (controls.getKey('UI_LEFT', JUST_PRESSED) || controls.getKey('UI_RIGHT', JUST_PRESSED))
								{
									changeCategory();
									changeSelection(0, []);
								}
							}
					}
				}
			}
		}

		if (categoryID == 2)
		{
			for (sprite in globalGroupManager.members)
			{
				var controlledSprite = cast(sprite, OptionsSprite);

				controlledSprite.y = Tools.lerpBound(controlledSprite.y,
					dimmer.y + 80 + ((controlledSprite.height + 10) * controlledSprite.selectionIndex),
					elapsed * 14.8);

				if (controlledSprite.y + controlledSprite.height <= dimmer.y || controlledSprite.y >= dimmer.y + dimmer.height)
				{
					controlledSprite.visible = false;
					controlledSprite.clipRect = null;
				}
				else
				{
					controlledSprite.visible = true;
					controlledSprite.clipRect = new FlxRect(dimmer.x - controlledSprite.x, dimmer.y - controlledSprite.y, dimmer.width, dimmer.height);
				}
			}
		}

		disableControlTimer -= elapsed;

		super.update(elapsed);
	}

	private var disableControlTimer:Float = 0.0;

	override function closeSubState():Void
	{
		persistentUpdate = true;

		super.closeSubState();
	}

	public var controlsCategory:Int = 0;

	public function changeCategory():Void
	{
		controlsCategory = FlxMath.wrap(controlsCategory + 1, 0, 1);
	}

	public function changeSelection(change:Int = 0, keys:Array<Int>, mouse:Bool = false)
	{
		if (curSelected[categoryID + 1] == null)
			curSelected[categoryID + 1] = 0;

		if (globalGroupManager.members.length == 0)
			return;

		var curSelection:Int = curSelected[categoryID + 1];

		if (!mouse)
			curSelection = FlxMath.wrap(curSelection + change, 0, globalGroupManager.members.length - 1);
		else
			curSelection = FlxMath.wrap(change, 0, globalGroupManager.members.length - 1);

		curSelected[categoryID + 1] = curSelection;

		var range:Int = 0;

		if (categoryID == 2)
		{
			for (object in globalGroupManager.members)
			{
				var bindControlObject:OptionsSprite = cast(object, OptionsSprite);
				bindControlObject.selectionIndex = range - curSelection;
				range++;
			}
		}

		if (change != 0 && (!mouse && categoryID != 2))
			InternalHelper.playSound(SCROLL, 0.75);

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
						}
						else
							textObj.alpha = 0.6;
					}
				}
			case 0 | 1 | 2:
				{
					for (text in globalGroupManager.members)
					{
						var textObj:OptionsSprite = cast(text, OptionsSprite);

						if (textObj.isSelected = ((mouse && FlxG.mouse.overlaps(textObj)) || (!mouse && textObj.ID == curSelection)))
							description.text = textObj.description;
					}
				}
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

typedef CategoryOption =
{
	var name:String;
	var description:String;
	var saveHolder:String;
	var defaultValue:Dynamic;
	var ?bound:{min:Int, max:Int};
	var ?choices:Array<Dynamic>;
	var type:Int;
}

typedef CategoryInfo =
{
	var name:String;
	var description:String;
}
