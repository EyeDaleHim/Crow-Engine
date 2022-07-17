package songinfo;

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

	public var stage:StageInfo;
	public var UI_box:FlxUITabMenu;
	public var camHUD:FlxCamera;
	public var stageSprites:Array<AttachedSprite> = [];
	public var currentSprite:AttachedSprite;
	public var camFollow:FlxObject;

	override function create()
	{
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		var GRID_SIZE = 64;
		var gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		FlxG.camera.follow(camFollow, null, 1);

		var tabs = [
			{name: "Stage", label: 'Stage'},
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
	var addSpriteButton:FlxUIButton;

	function createSpriteUI()
	{
		var UI_spriteTitle = new FlxUIInputText(12, 50, 70, "", 8);
		curSpriteTitle = UI_spriteTitle;

		var UI_spriteName = new FlxUIInputText(12, 90, 70, "", 8);
		curSpriteImage = UI_spriteName;

		var UI_spritePosX = new FlxUINumericStepper(12, 130, 10, 0, -FlxMath.MAX_VALUE_FLOAT, FlxMath.MAX_VALUE_FLOAT, 1);
		curSpritePosX = UI_spritePosX;

		var UI_spritePosY = new FlxUINumericStepper(102, 130, 10, 0, -FlxMath.MAX_VALUE_FLOAT, FlxMath.MAX_VALUE_FLOAT, 1);
		curSpritePosY = UI_spritePosY;

		var UI_spriteScrollX = new FlxUINumericStepper(12, 190, 0.10, 1.0, -10, 10, 2);
		curSpriteScrollX = UI_spriteScrollX;

		var UI_spriteScrollY = new FlxUINumericStepper(102, 190, 0.10, 1.0, -10, 10, 2);
		curSpriteScrollY = UI_spriteScrollY;

		addSpriteButton = new FlxUIButton(12, 400, "Add Sprite", function()
		{
		});

		var tab_group_sprite = new FlxUI(null, UI_box);
		tab_group_sprite.name = 'Sprite';

		tab_group_sprite.add(new FlxText(10, 30, 0, "Current Sprite Name"));
		tab_group_sprite.add(new FlxText(10, 70, 0, "Sprite Path"));
		tab_group_sprite.add(new FlxText(10, 110, 0, "Position X"));
		tab_group_sprite.add(new FlxText(100, 110, 0, "Position Y"));
		tab_group_sprite.add(new FlxText(10, 170, 0, "Scroll Factor X"));
		tab_group_sprite.add(new FlxText(100, 170, 0, "Scroll Factor Y"));
		tab_group_sprite.add(UI_spriteTitle);
		tab_group_sprite.add(UI_spriteName);
		tab_group_sprite.add(UI_spritePosX);
		tab_group_sprite.add(UI_spritePosY);
		tab_group_sprite.add(UI_spriteScrollX);
		tab_group_sprite.add(UI_spriteScrollY);
		tab_group_sprite.add(addSpriteButton);

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

			// if wanted, make a PR of this and tell me why you uncommented this
			// FlxG.mouse.visible = !FlxG.mouse.pressedRight;
		}
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
