package states.substates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import objects.Alphabet;

using StringTools;

class PauseSubState extends MusicBeatSubState
{
	public var background:FlxSprite;

	public var textList:Array<String> = [PlayState.current.songName, PlayState.current.songDiffText.toUpperCase()];
	public var textGroups:FlxTypedGroup<FlxText>;

	public static var selectionList:Array<SelectionCallback> = [
		{
			name: 'Resume',
			callback: function()
			{
				FlxG.state.subState.close();
			}
		},
		{
			name: 'Restart Song',
			callback: function()
			{
				FlxTween.tween(PlayState.current.pauseCamera, {alpha: 0.0}, 0.5, {ease: FlxEase.quadOut});
				MusicBeatState.switchState(new states.PlayState());
			}
		},
		{
			name: 'Exit To Menu',
			callback: function()
			{
				FlxTween.tween(PlayState.current.pauseCamera, {alpha: 0.0}, 0.5, {ease: FlxEase.quadOut});
				/*if (PlayState.isStoryMode)
					MusicBeatState.switchState(new ) */
				MusicBeatState.switchState(new states.menus.FreeplayState());
			}
		}
	];

	public var selectionGroup:FlxTypedGroup<Alphabet>;

	public var curSelected:Int = 0;

	override function create()
	{
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		background.active = false;
		background.alpha = 0.0;
		add(background);

		textGroups = new FlxTypedGroup<FlxText>();
		add(textGroups);

		selectionGroup = new FlxTypedGroup<Alphabet>();
		add(selectionGroup);

		for (text in textList)
		{
			var textObject:FlxText = new FlxText(0, 0, 0, text, 32);
			textObject.setFormat(Paths.font('vcr.ttf'), 32);
			textObject.updateHitbox();
			textObject.setPosition(FlxG.width - (textObject.width + 20), 20 + (2.5 + textObject.height * textList.indexOf(text)));
			textObject.alpha = 0.0;
			textGroups.add(textObject);

			var formerY:Float = textObject.y;
			textObject.y -= 5;

			FlxTween.tween(textObject, {alpha: 1.0, y: formerY}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 + (0.2 * textList.indexOf(text))});
		}

		for (selection in selectionList)
		{
			var selectionObject:Alphabet = new Alphabet(0, (70 * selectionList.length) + 30, selection.name, true, false);
			selectionObject.isMenuItem = true;
			selectionObject.targetY = selectionList.length;
			selectionObject.ID = selectionList.length;
			selectionGroup.add(selectionObject);
		}

		FlxTween.tween(background, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [PlayState.current.pauseCamera];

		changeSelection();

		super.create();
	}

	private var firstFrame:Bool = false; // whoops

	override function update(elapsed:Float)
	{
		if (!firstFrame)
		{
			firstFrame = true;
			super.update(elapsed);
			return;
		}

		if (controls.getKey('ACCEPT', JUST_PRESSED))
		{
			if (selectionList[curSelected].callback != null)
				selectionList[curSelected].callback();
		}
		else
		{
			if (controls.getKey('UI_UP', JUST_PRESSED))
				changeSelection(-1);
			else if (controls.getKey('UI_DOWN', JUST_PRESSED))
				changeSelection(1);
		}

		// leave debug key editors in here, not playstate

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		curSelected = FlxMath.wrap(curSelected + change, 0, selectionList.length - 1);

		var range:Int = 0;

		for (selection in selectionGroup.members)
		{
			selection.targetY = range - curSelected;
			range++;

			if (selection.targetY == 0)
			{
				selection.alpha = 1.0;
			}
			else
			{
				selection.alpha = 0.6;
			}
		}
	}
}

typedef SelectionCallback =
{
	var name:String;
	var callback:Void->Void;
}
