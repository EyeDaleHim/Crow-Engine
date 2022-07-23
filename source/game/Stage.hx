package game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.typeLimit.OneOfTwo;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import openfl.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import haxe.Json;

class Stage
{
	public var listedNames:Map<String, FlxSprite> = [];
	public var parsedStage:StageInfo;

	public function new(file:String, ?group:GroupSprites)
	{
		var target:Dynamic = PlayState.current;
		if (group != null)
			target = group;

		switch (file)
		{
			// case 'yourstagename': replace this with your stage name if you wanna hardcode stuff, but make sure to do target.add() instead of add()
			default:
				{
					if (Assets.exists(Paths.getPath('images/stages/$file.json', IMAGE, null)))
					{
						// for characters we'll not be manually placing them here
						parsedStage = cast Json.parse(Assets.getText(Paths.getPath('images/stages/$file.json', IMAGE, null)));

						for (spr in parsedStage.sprites)
						{
							var newSprite:FlxSprite = new FlxSprite(spr.x, spr.y);
							if (spr.filePath != null)
							{
								if (spr.isAnimated)
								{
									newSprite.frames = Paths.getSparrowAtlas(spr.filePath);
									for (sparrows in spr.sparrow)
									{
										if (sparrows.indices.length == 0)
											newSprite.animation.addByPrefix(sparrows.animName, sparrows.xmlName, sparrows.framerate, sparrows.looped);
										else
											newSprite.animation.addByIndices(sparrows.animName, sparrows.xmlName, sparrows.indices, '.png',
												sparrows.framerate, sparrows.looped);
									}
								}
								else
									newSprite.loadGraphic(spr.filePath);
							}
							else
							{
								if (spr.graphicData != null)
									newSprite.makeGraphic(spr.graphicData.width, spr.graphicData.height, spr.graphicData.color);
								else
									FlxG.log.error('ERROR! Sprite ${spr.name} from images/stages/${file}.json has no/confusing graphic data! Setting to default sprite.');
							}

							newSprite.scrollFactor.set(spr.scrollFactor.x, spr.scrollFactor.y);
							listedNames.set(spr.name, newSprite);
							if (Std.isOfType(target, Array))
								target.push(newSprite);
							else if (Std.isOfType(target, FlxTypedGroup))
								target.add(newSprite);
							else
								target.add(newSprite);
						}
					}
					else
					{
						FlxG.log.error('ERROR! Stage File images/stages/${file}.json non-existent!');
					}
				}
		}
	}
}

class StageEditorState extends MusicBeatState
{
	public static var lastStage:String;

	var _file:FileReference;

	public var bg:FlxSprite;

	public var stage:StageInfo;
	public var UI_box:FlxUITabMenu;

	public var camBG:FlxCamera;
	public var camHUD:FlxCamera;
	public var camFollow:FlxObject;

	public var stageSprites:Array<AttachedSprite> = [];
	public var currentSprite:AttachedSprite;

	override function create()
	{
		camBG = new FlxCamera();
		FlxG.cameras.insert(camBG, false, 0);

		FlxG.camera.bgColor = 0;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.alpha = 0.3;
		bg.scrollFactor.set();
		bg.antialiasing = true;
		bg.cameras = [camBG];
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 1);

		var tabs = [
			{name: "Camera", label: 'Camera'},
			{name: "Sprite", label: 'Sprite'},
			{name: "Characters", label: 'Characters'},
			{name: "Stage Info", label: 'Stage Info'}
		];

		UI_box = new FlxUITabMenu(null, null, tabs, null, true);

		UI_box.resize(300, FlxG.height);
		UI_box.x = FlxG.width - 300;
		UI_box.cameras = [camHUD];
		UI_box.scrollFactor.set();
		add(UI_box);

		FlxG.mouse.visible = true;

		createSpriteUI();

		super.create();
	}

	var curSpriteTitle:FlxInputText;
	var curSpriteImage:FlxInputText;
	var curSpritePosX:FlxUINumericStepper;
	var curSpritePosY:FlxUINumericStepper;
	var curSpriteScrollX:FlxUINumericStepper;
	var curSpriteScrollY:FlxUINumericStepper;
	var curSpriteScaleX:FlxUINumericStepper;
	var curSpriteScaleY:FlxUINumericStepper;

	var addSpriteButton:FlxUIButton;
	var removeSpriteButton:FlxUIButton;

	function createSpriteUI()
	{
		var UI_spriteTitle = new FlxUIInputText(12, 50, 70, "", 8);
		UI_spriteTitle.name = 'sprite_name';
		curSpriteTitle = UI_spriteTitle;

		var UI_spriteName = new FlxUIInputText(12, 90, 70, "", 8);
		UI_spriteName.name = 'sprite_path';
		curSpriteImage = UI_spriteName;

		var UI_spritePosX = new FlxUINumericStepper(12, 130, 10, 0, -FlxMath.MAX_VALUE_FLOAT, FlxMath.MAX_VALUE_FLOAT, 1);
		UI_spritePosX.name = 'sprite_posX';
		curSpritePosX = UI_spritePosX;

		var UI_spritePosY = new FlxUINumericStepper(102, 130, 10, 0, -FlxMath.MAX_VALUE_FLOAT, FlxMath.MAX_VALUE_FLOAT, 1);
		UI_spritePosY.name = 'sprite_posY';
		curSpritePosY = UI_spritePosY;

		var UI_spriteScrollX = new FlxUINumericStepper(12, 170, 0.10, 1.0, -10, 10, 2);
		UI_spriteScrollX.name = 'sprite_scrollX';
		curSpriteScrollX = UI_spriteScrollX;

		var UI_spriteScrollY = new FlxUINumericStepper(102, 170, 0.10, 1.0, -10, 10, 2);
		UI_spriteScrollY.name = 'sprite_scrollY';
		curSpriteScrollY = UI_spriteScrollY;

		var UI_spriteScaleX = new FlxUINumericStepper(12, 210, 0.10, 1.0, -10, 10, 2);
		UI_spriteScrollY.name = 'sprite_scaleX';
		curSpriteScaleX = UI_spriteScaleX;

		var UI_spriteScaleY = new FlxUINumericStepper(102, 210, 0.10, 1.0, -10, 10, 2);
		UI_spriteScaleY.name = 'sprite_scaleY';
		curSpriteScaleY = UI_spriteScaleY;

		addSpriteButton = new FlxUIButton(12, 400, "Add New Sprite", function()
		{
		});

		removeSpriteButton = new FlxUIButton(102, 400, "Remove Selected Sprite", function()
		{
		});

		var tab_group_sprite = new FlxUI(null, UI_box);
		tab_group_sprite.name = 'Sprite';

		var i:Int = 0;
		var addText:(Float, Float, String, ?Bool) -> FlxText = function(x:Float, y:Float, text:String, ?increment:Bool)
		{
			if (increment)
				i++;
			return new FlxText(x, y + (40 * (i - 1)), 0, text);
		}

		tab_group_sprite.add(addText(10, 30, "Sprite Name", true));
		tab_group_sprite.add(addText(10, 30, "Sprite Path", true));
		tab_group_sprite.add(addText(10, 30, "Position X", true));
		tab_group_sprite.add(addText(100, 30, "Position Y"));
		tab_group_sprite.add(addText(10, 30, "Scroll Factor X", true));
		tab_group_sprite.add(addText(100, 30, "Scroll Factor Y"));
		tab_group_sprite.add(addText(10, 30, "Scale X", true));
		tab_group_sprite.add(addText(100, 30, "Scale Y"));
		tab_group_sprite.add(UI_spriteTitle);
		tab_group_sprite.add(UI_spriteName);
		tab_group_sprite.add(UI_spritePosX);
		tab_group_sprite.add(UI_spritePosY);
		tab_group_sprite.add(UI_spriteScrollX);
		tab_group_sprite.add(UI_spriteScrollY);
		tab_group_sprite.add(UI_spriteScaleX);
		tab_group_sprite.add(UI_spriteScaleY);
		tab_group_sprite.add(addSpriteButton);
		tab_group_sprite.add(removeSpriteButton);

		// too lazy to manually change all of them lol!
		for (member in tab_group_sprite.members)
		{
			member.y -= 20;
		}

		UI_box.addGroup(tab_group_sprite);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		updateSprite();
		updateCamera();
	}

	private var isNotSelectingSprite:Bool = false;

	private function updateSprite():Void
	{
		if (currentSprite != null)
		{
			if (currentSprite.data != null)
			{
				currentSprite.data.name = curSpriteTitle.text;
			}
		}
	}

	private var heldPoint:FlxPoint = FlxPoint.get();
	private var currentPoint:FlxPoint = FlxPoint.get();

	private function updateCamera():Void
	{
		if (!isNotSelectingSprite)
		{
			if (FlxG.mouse.justPressedRight)
				heldPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

			if (FlxG.mouse.pressedRight)
			{
				currentPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);

				camFollow.x = camFollow.x + (heldPoint.x - currentPoint.x);
				camFollow.y = camFollow.y + (heldPoint.y - currentPoint.y);

				heldPoint.set(FlxG.mouse.getScreenPosition().x, FlxG.mouse.getScreenPosition().y);
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.camera.zoom += ((FlxG.mouse.wheel) / 10);
				if (FlxG.camera.zoom < 0.1)
					FlxG.camera.zoom = 0.1;
				if (FlxG.camera.zoom > 3)
					FlxG.camera.zoom = 3;
			}
		}
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		super.getEvent(id, sender, data, params);
	}

	private function addAnonymousSprite():Void
	{
	}
}

class AttachedSprite
{
	public var data:SpriteData;
	public var hitbox:Array<FlxSprite>;
}

typedef GroupSprites = OneOfTwo<FlxTypedGroup<FlxSprite>, Array<FlxSprite>>;

typedef StageInfo =
{
	var charPositions:CharacterPositions; // 0 = dad, 1 = gf, 2 = bf
	var camPositions:CharacterPositions; // i understand but its better than making a duplicate :(((
	var sprites:Array<SpriteData>;
	var engineVersion:Int;
}

typedef CharacterPositions = Array<FlxPoint>;

typedef SpriteData =
{
	var name:String;
	var filePath:String;
	var x:Float;
	var y:Float;
	var scrollFactor:FlxPoint;
	var isAnimated:Bool;
	var graphicData:GraphicData;
	var sparrow:Array<SparrowData>;
}

typedef GraphicData =
{
	var width:Int;
	var height:Int;
	var color:Int;
}

typedef SparrowData =
{
	var xmlName:String;
	var animName:String;
	var force:Bool;
	var framerate:Int;
	var looped:Bool;
	var indices:Array<Int>;
}
