package songinfo;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import flixel.addons.display.FlxGridOverlay;
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
						var stageParsed:StageInfo = Json.parse(Assets.getText(Paths.getPath('images/stages/$file.json', IMAGE, null)));
						parsedStage = cast stageParsed; // for characters, we'll not be manually placing them here

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

	override function create()
	{
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);

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

        createSpriteUI();

		super.create();
	}

    var curSpriteTitle:FlxInputText;

    function createSpriteUI()
    {
        var UI_spriteTitle = new FlxUIInputText(12, 50, 70, "", 8);
        curSpriteTitle = UI_spriteTitle;

        var tab_group_sprite = new FlxUI(null, UI_box);
		tab_group_sprite.name = 'Sprite';

        tab_group_sprite.add(new FlxText(10, 30, 0, "Current Sprite Name"));
        tab_group_sprite.add(UI_spriteTitle);

        UI_box.addGroup(tab_group_sprite);
    }
}

class AttachedSprite
{
    public var data:SpriteData;
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
