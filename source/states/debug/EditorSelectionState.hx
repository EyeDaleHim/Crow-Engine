package states.debug;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import objects.Alphabet;
import states.debug.*;
import states.debug.characters.*;
import states.debug.game.*;

class EditorSelectionState extends MusicBeatSubState
{
	public static var stateList:Map<String, Class<MusicBeatState>> = [
		'Character Editor' => CharacterEditorState,
		'Offset Editor' => OffsetEditorState,
		'Chart Editor' => ChartEditorState
	];

	public var onExit:Void->Void = null;

	public var background:FlxSprite;
	public var textGroup:FlxTypedGroup<Alphabet>;

	override function create()
	{
		background = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0.0;
		background.attributes.set('alphaRatio', 0.0);
		add(background);

		textGroup = new FlxTypedGroup<Alphabet>();
		add(textGroup);

		var len:Int = 0;
		for (text in stateList.keys())
		{
			len++;
		}

		for (text in stateList.keys())
		{
			var selectionObject:Alphabet = new Alphabet(0, (70 * len) + 30, text, true, false);
			selectionObject.isMenuItem = true;
			selectionObject.targetY = len;
			selectionObject.ID = len;
			textGroup.add(selectionObject);
		}

		cameras = [PlayState.current.pauseCamera];

		changeSelection();

		super.create();
	}

	public var curSelected:Int = 0;

	override function update(elapsed:Float)
	{
		background.attributes['alphaRatio'] += elapsed * 2;

		background.alpha = FlxEase.cubeOut(Math.min(background.attributes['alphaRatio'], 0.6));

		if (controls.getKey('BACK', JUST_PRESSED))
		{
			if (onExit != null)
			{
				onExit();
			}
			close();
		}
		else
		{
			if (controls.getKey('ACCEPT', JUST_PRESSED))
			{
				close();
				MusicBeatState.switchState(Type.createInstance(stateList[textGroup.members[curSelected].text], []));
			}
			else
			{
				if (controls.getKey('UI_UP', JUST_PRESSED))
					changeSelection(-1);
				else if (controls.getKey('UI_DOWN', JUST_PRESSED))
					changeSelection(1);
			}
		}

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0)
	{
		if (change != 0)
			FlxG.sound.play(Paths.sound('menu/scrollMenu'), 0.75);

		curSelected = FlxMath.wrap(curSelected + change, 0, textGroup.length - 1);

		var range:Int = 0;

		for (selection in textGroup.members)
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
