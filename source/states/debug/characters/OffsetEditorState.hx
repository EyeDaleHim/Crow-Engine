package states.debug.characters;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import sys.FileSystem;
import objects.character.Character;
import music.Song;

// temporary thing, will merge with character editor later
// also you're meant to use the flixel debug console, this is not intended for global use
class OffsetEditorState extends MusicBeatState
{
	public var selected:Int = 0;
	public var camFollow:FlxObject;

	public var background:FlxSprite;
	public var textGroup:FlxTypedGroup<FlxText>;
	public var character:Character;
	public var ghostCharacter:Character;

	public var bgCamera:FlxCamera;
	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;

	override function create()
	{
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();

		bgCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		bgCamera.bgColor.alpha = 0;
		FlxG.cameras.reset(bgCamera);

		gameCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		gameCamera.bgColor.alpha = 0;
		FlxG.cameras.add(gameCamera, false);

		hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor.alpha = 0;
		FlxG.cameras.add(hudCamera, false);

		gameCamera.zoom = 0.8;

		if (FlxG.sound.music != null)
			FlxG.sound.music.kill();

		background = new FlxSprite().loadGraphic(Paths.image("menus/freeplayBG"));
		background.scrollFactor.set();
		background.cameras = [bgCamera];
		add(background);

		textGroup = new FlxTypedGroup<FlxText>();
		textGroup.cameras = [hudCamera];
		add(textGroup);

		changeCharacter(Song.currentSong.opponent, false);

		add(ghostCharacter);
		add(character);

		if (states.PlayState.globalAttributes.exists('isPlaying'))
			destination = states.PlayState;

		gameCamera.follow(camFollow, null, 1);
		attributes.set('camZoom', 1.0);

		FlxG.mouse.getPositionInCameraView(gameCamera, (_lastPress == null ? (_lastPress = FlxPoint.get()) : _lastPress));

		super.create();
	}

	public var destination:Class<MusicBeatState> = null;

	private var _lastPress:FlxPoint;
	private var charOverlaps:Bool = false;

	override function update(elapsed:Float)
	{
		if (controls.getKey('BACK', JUST_PRESSED))
		{
			if (destination == null)
				destination = states.menus.MainMenuState;

			if (!Std.isOfType(destination, states.PlayState))
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

			MusicBeatState.switchState(Type.createInstance(destination, []));
		}
		else if (FlxG.mouse.justMoved)
		{
			FlxG.mouse.visible = true;

			if (FlxG.mouse.pressedRight)
			{
				FlxG.mouse.visible = false;

				var camPos = FlxG.mouse.getPositionInCameraView(gameCamera);

				camFollow.x = camFollow.x + (_lastPress.x - camPos.x);
				camFollow.y = camFollow.y + (_lastPress.y - camPos.y);

				FlxG.mouse.getPositionInCameraView(gameCamera, (_lastPress == null ? (_lastPress = FlxPoint.get()) : _lastPress));
			}
			else if (FlxG.mouse.justPressed)
			{
				// i got bored
				var lastPos:FlxPoint = character.getPosition();

				character.x -= character.offset.x;
				character.y -= character.offset.y;

				if (FlxG.mouse.overlaps(character, gameCamera))
					charOverlaps = true;

				character.setPosition(lastPos.x, lastPos.y);
			}
		}
		else if (FlxG.mouse.pressed)
		{
			if (charOverlaps)
			{
				var camPos = FlxG.mouse.getPositionInCameraView(gameCamera);

				var offset:FlxPoint = character.animOffsets[animationList[selected]];
				offset.x = Math.floor(offset.x + (_lastPress.x - camPos.x));
				offset.y = Math.floor(offset.y + (_lastPress.y - camPos.y));

				character.offset.set(offset.x, offset.y);

				formatTextOffset(textGroup.members[selected], animationList[selected], offset);

				FlxG.mouse.getPositionInCameraView(gameCamera, (_lastPress == null ? (_lastPress = FlxPoint.get()) : _lastPress));
			}
		}
		else
		{
			if (FlxG.mouse.wheel != 0)
				attributes['camZoom'] += FlxG.mouse.wheel / 30;

			if (FlxG.keys.pressed.SHIFT)
			{
				var valueKeys:Array<FlxPoint> = [FlxPoint.get(-1, 0), FlxPoint.get(0, 1), FlxPoint.get(0, -1), FlxPoint.get(1, 0)];
				var valueControls:Void->Array<Bool> = function()
				{
					var pushed:Array<Bool> = [];
					for (key in ['LEFT', 'DOWN', 'UP', 'RIGHT'])
					{
						pushed.push(controls.getKey('UI_$key', PRESSED));
					}

					return pushed;
				}

				if (valueControls().contains(true))
				{
					var keyList:Array<Bool> = valueControls();
					for (i in 0...keyList.length)
					{
						if (keyList[i])
						{
							character.animOffsets[animationList[selected]].subtractPoint(valueKeys[i]);
							character.offset.subtractPoint(valueKeys[i]);
						}
					}

					formatTextOffset(textGroup.members[selected], animationList[selected], character.animOffsets[animationList[selected]]);
				}

				if (FlxG.keys.justPressed.R)
					ghostCharacter.playAnim(animationList[selected]);
			}
			else
			{
				if (controls.getKey('UI_UP', JUST_PRESSED))
					changeSelection(-1);
				if (controls.getKey('UI_DOWN', JUST_PRESSED))
					changeSelection(1);
			}
		}

		if (!FlxG.mouse.pressed)
			charOverlaps = false;

		gameCamera.zoom = FlxMath.bound(Math.exp(Tools.lerpBound(Math.log(gameCamera.zoom), Math.log(attributes['camZoom']), 0.5 / elapsed)), 0.1, 3.0);

		super.update(elapsed);
	}

	public function changeSelection(change:Int = 0)
	{
		selected = Std.int(FlxMath.bound(selected + change, 0, textGroup.length - 1));

		if (textGroup.members.length != 0)
		{
			for (text in textGroup.members)
			{
				if (text == null)
					continue;
				if (text.ID == selected)
					text.color = FlxColor.YELLOW;
				else
					text.color = FlxColor.BLUE;
			}
		}

		if (character != null)
		{
			character.playAnim(animationList[selected], true);
		}
	}

	private var animationList:Array<String> = [];

	private function changeCharacter(name:String, player:Bool)
	{
		if (character != null)
		{
			character.destroy();
		}

		textGroup.clear();
		animationList = [];

		ghostCharacter = new Character(0, 0, name, player);
		ghostCharacter.cameras = [gameCamera];
		ghostCharacter.controlIdle = false;
		ghostCharacter.screenCenter();
		ghostCharacter.alpha = 0.3;

		character = new Character(0, 0, name, player);
		character.cameras = [gameCamera];
		character.controlIdle = false;
		character.screenCenter();

		var list:Array<String> = character.animation.getNameList();
		for (i in 0...list.length)
		{
			var animText:FlxText = new FlxText(0, 0, 0, "", 16);
			animText.ID = i;
			animText.setBorderStyle(OUTLINE, 0, 1.25, 1);
			animText.setPosition(10, 10 + (animText.height * i));
			formatTextOffset(animText, list[i], !character.animOffsets.exists(list[i]) ? FlxPoint.get() : character.animOffsets[list[i]]);
			textGroup.add(animText);

			animationList[i] = list[i];
		}

		changeSelection(-selected);
	}

	private function formatTextOffset(text:FlxText, animation:String, offset:FlxPoint):FlxText
	{
		text.text = '$animation: (X: ${offset.x}, Y: ${offset.y})';
		return text;
	}
}
